# Remote

Controls for tethered capture. Live view, its overlays and the histogram are omitted, because an agent cannot see them. Items marked † come from the app's resources and were not opened.

## Connection

Launch Remote with `open -g -b com.sony.Remote`. With a camera connected, the window's right panel shows the Shooting section and a battery indicator (an image with help `Battery Power Remaining`, with the percentage in the static text next to it). Without one, Remote lists cameras† (model, camera name, USB or IP connection, IP and MAC address, pairing state), and a row is double-clicked to connect.

## Shooting

| Control | Element | Notes |
| --- | --- | --- |
| Photo | button, help `Photo` | Takes a still. |
| Video | button, help `Video` | Starts and stops recording. |
| Interval timer | button, help `Interval timer shooting from this application` | Opens the interval dialog. |
| Shutter Half Press | button | Focuses and meters. |
| AEL, FEL, AWBL | buttons | Lock exposure, flash exposure or white balance. |
| Mode | three small buttons beside `Normal`, `Interval shooting on camera` and `Bulb timer shooting on camera` | The current mode is the static text after `Mode :`. |

After a shot, the status text changes to `Transferred image: (<file>). <n> files remaining`.

## Main Settings

Labels are static texts with two leading spaces: `  Mode`, `  Shutter Speed`, `  F`, `  ISO`, `  EV`, `  Flash`. Each value is a static text inside a tile. Pressing the tile opens a list picker ([closing it](automation.md#behaviour)), and two unlabelled buttons to the right of the value step it.

The CameraSettings menu has labelled steps: Shutter Speed, F, ISO, Exposure Comp. and Flash Comp., each with `+` and `-`. Press one and read the value back to learn its direction. When the F arrows are disabled, the aperture can't be set from the app; this is likely because the lens aperture ring is not at A.

Mode Dial Operation (CameraSettings menu, or the Camera Settings dialog) chooses whether the app (Application Priority) or the camera's dial (Camera Priority) controls dial-bound settings such as the exposure mode.

## Sub Settings

Buttons labelled by help text: File Format, RAW File Type, Quality, Image Size, Aspect Ratio, Drive Mode, White Balance, D-Range Optimizer, Focus Area, Metering Mode, Focus Mode, Flash Mode, Red Eye Reduction, Wireless Flash, Creative Look. Each opens a picker with the current value, option buttons labelled by help text (for example File Format offers `RAW`, `RAW & HEIF` and `HEIF` while the JPEG/HEIF Switch is on HEIF), and a Close button. The CameraSettings menu has the same items except Creative Look.

## Focus

- Toggle AF/MF: button, help `Toggle AF/MF`.
- Manual focus steps: Tools ▸ Near ▸ `<<<` `<<` `<` and Tools ▸ Far ▸ `>` `>>` `>>>`; more chevrons mean a larger step. The panel buttons for these share the help texts `Near` and `Far`, so prefer the menu items.

## Save Settings

Expand this section first if it is collapsed.

- Save in: a combo box whose value is the folder path. The `...` button picks a folder.
- File name: Auto or Manual (buttons with help `Auto` and `Manual`). In Manual, set the prefix (combo box, identifier `prefix`) and the starting number (field, identifier `startNo`).

## Settings dialog

Remote ▸ Settings:

- Preview: Display preview in Viewer opens each shot in Viewer. Display preview with the selected program does the same for another program.
- BULB shooting: an exposure time from 2 s to 180 min (minutes and seconds fields, Apply).

## Camera Settings dialog

Open it with the Camera Settings button at the bottom of the right panel.

- Image Transfer: Still Img. Save Dest. (PC Only, PC+Camera, Camera Only); PC Save Image Size (Original, 2M); RAW+H PC Save Image (which files of a RAW+HEIF pair to transfer).
- Mode Dial Operation: Application Priority or Camera Priority.
- JPEG/HEIF Switch: JPEG, HEIF(4:2:0) or HEIF(4:2:2).
- Exposure Ctrl Type: P/A/S/M Mode or Flexible Exp. Mode.

## Interval timer dialog†

Start now or after a delay in minutes; an interval from 10 s to 180 min; 2–1000 shots or no limit; Start. A progress window with a Stop button stays open while it runs.

## Shortcuts

These work only while Remote is frontmost, so press the matching menu items instead: Photo `1`, Video `⌃R`, interval timer `⌃I`, Shutter Half Press `G`, AEL `H`, FEL `N`, AWBL `J`, Toggle AF/MF `P`, Near `Q` `W` `E`, Far `R` `T` `Y`, Shutter Speed `S` / `⇧S`, F `C` / `⇧C`, ISO `I` / `⇧I`, EV `A` / `⇧A`, Flash `F` / `⇧F`, Interval shooting on camera `⌃T`.

## References

- [Connecting the camera to the computer](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/4_1_connection.php)
- [Operation panel](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/4_3_panels.php)
- [Remote shooting](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/4_5_remote.php)
- [Keyboard shortcuts](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/6_3_keyboard_shortcuts.php)
