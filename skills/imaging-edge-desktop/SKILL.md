---
name: imaging-edge-desktop
description: Drive Sony Imaging Edge Desktop on macOS (Remote, Edit and Viewer) through the Accessibility API for tethered capture, camera settings, ARW development and JPEG/TIFF export. Use whenever a task involves taking or tethering photos with the connected Sony camera, reading or changing its exposure, focus or file settings from the computer, adjusting Sony RAW (ARW) files in Imaging Edge Edit, or exporting or batch-exporting images through Imaging Edge, even when the app is not named.
---

# Imaging Edge Desktop

Remote shoots tethered and sets the camera. Edit develops and exports one RAW at a time. Viewer browses folders and batch-exports. Their bundle identifiers are `com.sony.Remote`, `com.sony.Edit` and `com.sony.Viewer`. This skill was written against version 4.1.00.

## Access

- Drive the apps with the bundled [ax helper](scripts/ax.swift). Build it once per session into a scratch directory with `swiftc -O -o <scratch>/ax scripts/ax.swift`, then run `<scratch>/ax trusted`.
- macOS checks Accessibility for the binary responsible for the shell, which can differ from the app that hosts the agent. When access is missing, `ax trusted` names that binary; ask the user to add it under System Settings › Privacy & Security › Accessibility.
- Without Screen Recording access there are no screenshots, so read all state from the Accessibility tree. Live view, Edit's image and tone curve, and Viewer's thumbnails are custom views with no Accessibility children.
- Touch only Remote, Edit and Viewer, and only as far as the task needs.

## Operate safely

- Shoot, record, start interval or bulb shooting, or change camera settings only when the task asks for it. Read the current values first and report what changed.
- Never press Delete All Pairing Information, Delete stored Access Authen. Info, or Delete Selected Version: none of them can be undone.
- Edit's Save writes the adjustments into the RAW file. Produce files with Output, and use Save only when the user wants the edits kept in the RAW.
- Keep the apps in the background. The helper posts input straight to an app's process, and an app in front would also receive the user's own typing: bare keys shoot in Remote, and set ratings or rotate images in Viewer.
- Look elements up with `ax find` before each action and identify them by help text, title or identifier. Paths are positional and shift whenever a window, dialog, popover or menu opens or closes.
- Re-read the affected value or window after each action to confirm the effect.
- Leave the apps as you found them: close dialogs with Cancel or Close, re-minimize restored windows, and collapse what you expanded.

## Choose the app

| Task | App | Read |
| --- | --- | --- |
| Shoot; change exposure, focus or file settings | Remote | [remote.md](references/remote.md) |
| Adjust a RAW | Edit | [edit.md](references/edit.md) |
| Export one image | Edit | [Output](references/edit.md#output) |
| Export many images | Edit or Viewer | [Batch export](#batch-export) |
| Browse or filter shots | Viewer | [viewer.md](references/viewer.md) |

Read [automation.md](references/automation.md) before driving dialogs, pickers, menus or value fields. It covers the helper's commands and the apps' Accessibility quirks.

## Capture

1. Check that a camera is connected: `ax find Remote Photo` returns the Photo button, and the battery indicator is present.
2. Read the Save Settings folder and file naming, then the Main Settings values.
3. Change settings with the labelled CameraSettings menu items, such as Shutter Speed ▸ +, or with the sub-setting pickers. Re-read each value afterwards.
4. Press **Photo**. Once the file is in the Save in folder, the status line reads `Transferred image: (<file>). 0 files remaining`. Confirm that the file exists before using it.

## Edit

1. Open RAWs from the shell with `open -g -b com.sony.Edit <files>`; `-g` keeps Edit in the background. Each file opens as a tab.
2. Set Creative Look first, because changing it resets every other adjustment.
3. Change each palette value through its value field or slider, then read it back ([palettes](references/edit.md#palettes)).
4. Reuse settings with Edit ▸ Image Processing Settings ▸ Copy and Paste, or Save… a named settings file for batch use.

## Batch export

- **Edit, fully scriptable**: open the files in Edit, apply the settings by pasting or loading them, then run Output on each tab. File ▸ Next Image moves to the next tab. Check the dialog's format, compression and folder each time.
- **Viewer, faster but needs the user**: File ▸ Export… runs a [Batch Processing](references/viewer.md#batch-processing) dialog over the selected thumbnails. It applies each RAW's own settings or one settings file, and sets the save format, folder and naming pattern. A human has to select the thumbnails, because the grid has no Accessibility elements and ignores keys posted while Viewer is in the background. Ask the user to select the images, then drive the dialog.

## References

- [Imaging Edge Desktop: Overview and Home screen](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/1_1_features.php)
