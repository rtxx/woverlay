# woverlay
Wallpaper overlay script for Windows, made with [AHK](https://www.autohotkey.com/).

Heavily infuenced by the awesome extension for GNOME DE [WallpaperOverlay](https://github.com/rishuinfinity/WallpaperOverlay), go check it out!

## Warning! Here be dragons! Proceed with caution!
This is just a proof of concept, it is **not** production ready, bugs should be expected! I only tested on my machine, so YMMV.

## Requirements
- [AHK](https://www.autohotkey.com/)
- [Magick Image](https://imagemagick.org/)
  - Note: Be sure that magic is on ```PATH```. The installer has this option enable by default.

## Install
- Download this repo and extract it.
- Go to [WallpaperOverlay](https://github.com/rishuinfinity/WallpaperOverlay), download the repo, extract it.
- Go to the extracted folder from ```WallpaperOverlay``` and copy the folder ```overlays```, located at ```src\overlays```, to ```woverlay``` root folder.
- Open ```settings.ini``` at ```woverlay root``` folder and change to your display resolution. The default is ```1920x1080```.
- Open ```woverlay.ahk``` and you are good to go!

## Settings
In ```settings.ini``` there are some options we can change:
- **overlayColor** - Color of the overlay. Only works if ```overlayUseAvgColor``` is ```FALSE```.
- **overlayUseAvgColor** - If set to ```TRUE```, it uses an average color from wallpaper.
- **displayRes** - Sets the target display resolution.

## Run it
Right click the tray icon. All the options are self-explanatory. Double click opens ```woverlay``` script folder.
