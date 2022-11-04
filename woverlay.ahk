#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
FileEncoding, UTF-8
#Persistent
#SingleInstance

; Woverlay - Makes a wallpaper with an overlay, inspired from https://github.com/rishuinfinity/WallpaperOverlay
; This is just a proof of concept, It's not production ready! Use at your own risk!
; What does it do:
; Picks an overlay from WallpaperOverlay repo, and applies to an arbitrary wallpaper.
; It can change the color of the overlay, on the settings ini. Includes a function that calculates the color from the wallpaper.
; It uses Magick Image (https://imagemagick.org/) so it won't work without it (duh). Please install it before use.

; Declare globals variables
global imgPath
global finalImg
global overlayPath
global overlayTempPath
global wallpaperDir
global overlayColor
global displayRes
global cacheDir

; Sets globals variables
setGlobals()
{
  imgPath = ""
  finalImg = ""
  overlayPath = %A_ScriptDir%\overlays
  overlayTempPath = ""
  cacheDir = %A_ScriptDir%\cache
  wallpaperDir = %A_ScriptDir%\wallpapers
  
  IniRead overlayName, settings.ini, WOVERLAY, overlayName
  IniRead overlayColor, settings.ini, WOVERLAY, overlayColor
  IniRead displayRes, settings.ini, WOVERLAY, displayRes
  
  if !FileExist(cacheDir)
    FileCreateDir, %cacheDir%
  if !FileExist(wallpaperDir)
    FileCreateDir, %wallpaperDir%
}
setGlobals()

; Simple tray mesnu
Menu, Tray, NoStandard
Menu, Tray, Add, woverlay, TrayMenu
Menu, Tray, Default, woverlay
Menu, Tray, Icon, C:\Windows\system32\shell32.dll,141, TrayMenu
Menu, Tray, Add, Change wallpaper, TrayMenu
Menu, Tray, Add, Change overlay, TrayMenu
Menu, Tray, Add ; separator
Menu, Tray, Add, Redo last wallpaper, TrayMenu
Menu, Tray, Add ; separator
Menu, Tray, Add, Open settings.ini, TrayMenu
Menu, Tray, Add ; separator
Menu, Tray, Add, Reload script, TrayMenu
Menu, Tray, Add, Exit, TrayMenu
Return

TrayMenu:
  ; Double click opens script folder
  if A_ThisMenuItem = woverlay
    Run, %A_ScriptDir% 
    
  ; Change wallpaper entry
  if A_ThisMenuItem = Change wallpaper
  {
    imgPath := imgPicker(0)
    if imgPath = ""
      Return
    
    overlay := overlayPicker(0)
    if overlay = ""
      Return

    overlayColorReplace()
    finalWallpaper := makeImg(imgPath,overlayTempPath)
    if finalWallpaper = ""
      Return
    else
    {
      ; sets wallpaper , needs test
      ;https://www.autohotkey.com/boards/viewtopic.php?t=70592
      DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, finalImg, UInt, 1)
      FileDelete, %cacheDir%\*    
      TrayTip, woverlay, Wallpaper set! , 1, 1    
    }
    Return
  }

 ; Change overlay entry
  if A_ThisMenuItem = Change overlay
  {
    overlayPicker(1)  
    Return
  }
  
  ; Redo the last wallpaper. Useful if you want to test several overlays without changing the wallpaper
  if A_ThisMenuItem = Redo last wallpaper
  {
    IniRead lastWallpaper, settings.ini, WOVERLAY, lastWallpaper
    if (lastWallpaper = "")
    {
      MsgBox, No wallpaper set yet! Use 'Change wallpaper'.
      Return
    }
    imgPath := imgPicker(1)
    if imgPath = ""
      Return
      
    overlay := overlayPicker(0)
    if overlay = ""
      Return

    overlayColorReplace()
    finalWallpaper := makeImg(imgPath,overlayTempPath)
    if finalWallpaper = ""
      Return
    else
    {
      ; sets wallpaper , needs test
      ;https://www.autohotkey.com/boards/viewtopic.php?t=70592
      DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, finalImg, UInt, 1)
      FileDelete, %cacheDir%\*    
      TrayTip, woverlay, Wallpaper set! , 1, 1    
    }

    Return
  }

  ; Open settings.ini
  if A_ThisMenuItem = Open settings.ini
  {
    ; Opens settings.ini and waits to close it
    RunWait, %A_ScriptDir%\settings.ini
    TrayTip, woverlay, Reloading script... , 1, 1
    ; Reloads the script to load settings.ini again
    Reload
    ;Return
  }
  
  ; Reloads the script
  if A_ThisMenuItem = Reload script
  {
    Reload
    Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
    IfMsgBox, Yes, Edit
    Return
  }
  
  ; Exit the script
  if A_ThisMenuItem = Exit
    ExitApp

Return


; imgPicker : Picks wallpaper to use. 
; Arguments
; useLastWallpaper -> If '1' then use the last wallpaper the user selected.
; Returns
; imgPath -> Path for the wallpaper. This path is the cache version of the wallpaper selected, original wallpaper will never be touched
imgPicker(useLastWallpaper)
{
  if (useLastWallpaper = 1)
  {
    ; Reads lastWallpaper value from setting.ini
    IniRead lastWallpaper, settings.ini, WOVERLAY, lastWallpaper
    ; Gets lastWallpaper name without extension
    SplitPath, lastWallpaper, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    ; Copies lastWallpaper to cache folder
	  FileCopy, %lastWallpaper%, %cacheDir%\%OutFileName%, 1
    ; Sets image path
	  imgPath = %cacheDir%\%OutFileName%
    ; Resets useLastWallpaper flag
    useLastWallpaper = 0
    Return imgPath
  }
  else
  {
    ; Opens file explorer dialog, only shows pngs and jpgs
    FileSelectFile, SelectedFile, 3, , Open wallpaper, Images (*.png; *.jpg; *.jpeg)
    ; If the user cancels, set the image path to empty
    if (SelectedFile = "")
    {
      imgPath = ""
      Return imgPath
    }
    else
	  { 
      ; Gets selected wallpaper name without extension
	    SplitPath, SelectedFile, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
      ; Copies selected wallpaper to cache folder
	    FileCopy, %SelectedFile%, %cacheDir%\%OutFileName%, 1
      ; Sets image path
	    imgPath = %cacheDir%\%OutFileName%
      ; Sets lastWallpaper to settings.ini
      IniWrite, %SelectedFile%, settings.ini, WOVERLAY, lastWallpaper
      Return imgPath
  	}
  }
}

; overlayPicker : Picks overlay to use. 
; Arguments
; userSelect -> If '1' then asks the user for an overlay. If '0' it uses the overlay set on the settings.ini
; Returns
; nothing -> Only returns 0 to check if the user cancelled the file explorer dialog
overlayPicker(userSelect)
{
  if (userSelect = 1)
  {
    ; Opens file explorer dialog, only shows svgs
    FileSelectFile, SelectedFile, 3, %overlayPath%\ , Open overlay, Overlays (*.svg)
    ; If the user cancels, returns 0
    if (SelectedFile = "")
      Return 0
    else
    {
      ; Gets selected overlay name without extension
	    SplitPath, SelectedFile, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
      ; Sets selected overlay to settings.ini
	    IniWrite, %OutFileName%, settings.ini, WOVERLAY, overlayName
      ; tray tip to inform the user
      TrayTip, woverlay, Next wallpaper will use '%OutFileName%'. , 1, 1
    }
  }
  if (userSelect = 0)
  {
    ; Reads overlayName value from setting.ini
    IniRead overlayName, settings.ini, WOVERLAY, overlayName
    ; Copies overlay to cache folder
    FileCopy, %overlayPath%\%overlayName%, %cacheDir%\%overlayName%, 1
    ; Sets temporary overlay. This path is the cache version of the overlay selected, original overlay will never be touched
    overlayTempPath = %cacheDir%\%overlayName%
    Return
  }
}

; overlayColorReplace : Replace overlay svg with desire color
; Has 2 modes, Auto and Manual
; Auto Mode -> Uses Magick Image and gets an average color from wallpaper
; Manual Mode -> Uses color set from settings.ini
; Arguments
; nothing 
; Returns
; nothing
overlayColorReplace()
{
  ; Reads overlayUseAvgColor value from setting.ini 
  IniRead overlayUseAvgColor, settings.ini, WOVERLAY, overlayUseAvgColor
  ; If set to 'TRUE' then gets auto color from wallpaper

  if (overlayUseAvgColor = "TRUE")
    overlayColor := getImgColorAvg(imgPath) 

  ; Reads svg file as text 
  FileRead, overlayFile, %overlayTempPath%
  ; Searchs for the color "#0000ff" and replaces all entries with the new color
  overlayFile:= StrReplace(overlayFile, "#0000ff", overlayColor)
  ; Deletes old cached overlay file and makes a new one with the new color
  FileDelete, %overlayTempPath%
  FileAppend, %overlayFile%, %overlayTempPath%

  ; Sets lastOverlayColor to settings.ini
  IniWrite, %overlayColor%, settings.ini, WOVERLAY, lastOverlayColor
  Return
}

; getImgColorAvg : Calculates average color from wallpaper
; How it works:
; Uses Image Magick to convert the wallpaper. It resizes the image to a 1x1 pixel and outputs a txt with the result.
; Example output
;    # ImageMagick pixel enumeration: 1,1,0,255,srgb
;    0,0: (65,77,79)  #414D4F  srgb(25.3472%,30.2279%,30.986%)
; Arguments
; imgPath -> wallpaper path 
; Returns
; colorAvg -> color in hex value i.e #0000ff
getImgColorAvg(imgPath)
{
  ; Gets wallpaper path name without extension
  SplitPath, imgPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
   
  commands=
  (	join&
    magick convert "%imgPath%" -resize 1x1 "%cacheDir%\%OutNameNoExt%.txt"
  )
  ; Runs magickimage in a terminal
  RunWait, %comspec% /c %commands% ,,Hide
  ; Reads the resulting txt file and only saves the last line
  Loop, read, %cacheDir%\%OutNameNoExt%.txt
    lastLine := A_LoopReadLine
  ; Search last line from txt for a #
  hexPos := InStr(lastLine,"#")
  ; Copies the characters from the position 'hexPos' plus 7 more characters
  colorAvg := SubStr(lastLine, hexPos , 7)
  Return colorAvg
}

; makeImg : Makes the final wallpaper
; Arguments
; imgPath -> wallpaper path 
; overlayTempPath -> overlay path
; Returns
; finalImg -> Path to the resulting wallpaper
makeImg(imgPath,overlayTempPath)
{
  ; Gets wallpaper path name without extension
  SplitPath, imgPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
  ; Reads overlayName and lastOverlayColor values from setting.ini 
  IniRead overlayName, settings.ini, WOVERLAY, overlayName
  IniRead lastOverlayColor, settings.ini, WOVERLAY, lastOverlayColor
  ; Removes last 4 characters from overlay name, ie, removes '.svg'. useful because the finalImg use this var to construct its name
  overlayNameWithoutExt := SubStr(overlayName, 1, -4)
  ; Checks if wallpaper exists. If a wallpaper with a name with
  ; Display Resolution
  ; Overlay Name
  ; Overlay Color
  ; exists, then we assume it's the same configuration we are about to make. it prompts the user if we want to make it anyway.
  ; if we dont make the image, then ii uses the wallpaper already avaiable.
  checkWallpaper = %wallpaperDir%\%OutNameNoExt%_%displayRes%_%overlayNameWithoutExt%_%lastOverlayColor%.png
  ; Replaces all spaces with '_' on the final file name
  ;checkWallpaper := StrReplace(checkWallpaper, A_Space, "_")
  if FileExist(checkWallpaper)
  {
    MsgBox, 4, Attention!, Wallpaper with selected overlay and colors already exists!`nFound at: %checkWallpaper%`nDo you want to make a new the image anyway?
    IfMsgBox Yes
    {
      ; Sets the name for the final wallpaper image
      finalImg = %wallpaperDir%\%OutNameNoExt%_%displayRes%_%overlayNameWithoutExt%_%lastOverlayColor%.png
      ; Replaces all spaces with '_' on the final file name
      ;finalImg := StrReplace(finalImg, A_Space, "_")
      
      commands=
      (	join&
        magick convert "%imgPath%" -resize "%displayRes%"^! -gravity center -extent "%displayRes%" "%imgPath%"
        magick convert -background none "%overlayTempPath%" -resize "%displayRes%"^! -gravity center -extent "%displayRes%" "%cacheDir%\overlay-temp.png"
        magick composite "%cacheDir%\overlay-temp.png" "%imgPath%" "%finalImg%"
      )
      ; Runs magickimage in a terminal
      ; 1st line -> converts the wallpaper to the resolution set in settings.ini
      ; 2nd line -> converts the overlay to the resolution set in settings.ini
      ; 3rd line -> 'glues' overlay and wallpaper together
      RunWait, %comspec% /c %commands% ,,Hide
     
      ; Checks if finalImg exists, if does not exits, something went wrong with magick
      if FileExist(finalImg)
        Return finalImg
      else
      {
        Msgbox, Something went wrong!
        finalImg = ""
        Return finalImg
      }
    }
    ifMsgbox No
    {
      ; Sets the name for the final wallpaper image
      finalImg = %wallpaperDir%\%OutNameNoExt%_%displayRes%_%overlayNameWithoutExt%_%lastOverlayColor%.png
      ; Replaces all spaces with '_' on the final file name
      ;finalImg := StrReplace(finalImg, A_Space, "_")
      Return finalImg
    }
  }
  else
  {
    ; Sets the name for the final wallpaper image
    finalImg = %wallpaperDir%\%OutNameNoExt%_%displayRes%_%overlayNameWithoutExt%_%lastOverlayColor%.png
    ; Replaces all spaces with '_' on the final file name
    ;finalImg := StrReplace(finalImg, A_Space, "_")
    
    commands=
    (	join&
      magick convert "%imgPath%" -resize "%displayRes%"^! -gravity center -extent "%displayRes%" "%imgPath%"
      magick convert -background none "%overlayTempPath%" -resize "%displayRes%"^! -gravity center -extent "%displayRes%" "%cacheDir%\overlay-temp.png"
      magick composite "%cacheDir%\overlay-temp.png" "%imgPath%" "%finalImg%"
    )
    RunWait, %comspec% /c %commands% ,,Hide
    ; Checks if finalImg exists, if does not exits, something went wrong with magick
    if FileExist(finalImg)
      Return finalImg
    else
    {
      Msgbox, Something went wrong!
      finalImg = ""
      Return finalImg
    }
  }
}
