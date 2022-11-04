# woverlay
Wallpaper overlay script for Windows, made with [AHK](https://www.autohotkey.com/).

Heavily infuenced by the awesome extension for GNOME DE [WallpaperOverlay](https://github.com/rishuinfinity/WallpaperOverlay), go check it out!

| ![Mass Effect Alliance](https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/fa223523-406d-48ef-bff6-d045d1b9544b/da2cw6n-5a0565f6-95e8-408e-b61e-c8517b038ac5.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7InBhdGgiOiJcL2ZcL2ZhMjIzNTIzLTQwNmQtNDhlZi1iZmY2LWQwNDVkMWI5NTQ0YlwvZGEyY3c2bi01YTA1NjVmNi05NWU4LTQwOGUtYjYxZS1jODUxN2IwMzhhYzUuanBnIn1dXSwiYXVkIjpbInVybjpzZXJ2aWNlOmZpbGUuZG93bmxvYWQiXX0.i_GH6w-Un_k5NRfk3SAu2hMBDjsFkcG6OjRiI1Klrjw)  |
|---|

| ![Half Pellet Auto Color](https://raw.githubusercontent.com/rtxx/woverlay/main/me_alliance_1920x1080_Half%20Pellet%20Right_%23BFC3C9.png)  |  ![Half Pellet Manual Color](https://raw.githubusercontent.com/rtxx/woverlay/main/me_alliance_1920x1080_Half%20Pellet%20Right_%2341608f.png) |
|---|---|
|  ![Rectangule Emboss Auto Color](https://raw.githubusercontent.com/rtxx/woverlay/main/me_alliance_1920x1080_Rectangle%20Emboss_%23BFC3C9.png) |  ![Rectangule Emboss Manual Color](https://raw.githubusercontent.com/rtxx/woverlay/main/me_alliance_1920x1080_Rectangle%20Emboss_%2341608f.png) |

 [Image source](https://www.deviantart.com/solidcell/art/Alliance-Wallpaper-1-608622575)
| ![woverlay](https://raw.githubusercontent.com/rtxx/woverlay/main/woverlay.png) |
|---|

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
