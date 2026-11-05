# Viewer

Controls for finding shots and exporting them in batch. Rating, labels, collections, comparison and printing are omitted. Items marked † come from the app's resources and were not opened.

## Window

- Launch it with `open -g -b com.sony.Viewer`. Viewer opens no files from the shell.
- Its window is often minimized. Restore it with `ax setattr Viewer w0 AXMinimized false`, and minimize it again when done.

## Folders

- The left outline lists `Remote shots` (images taken with Remote), `Volumes` and `Users`. Each row has a disclosure triangle and a text field with the folder name.
- Expand a row with `ax press` on its triangle, and select a folder with `ax setattr Viewer <row> AXSelected true`. Viewer remembers the selection.
- Restore the previous folder selection when done.

## Filtering and selection

- Below the thumbnails, a filter combo box (`Do not filter`) and a file-format combo box (`ALL`) narrow what is shown. The same filters are in Tools ▸ Filter: rating, model, lens, file format and color label.
- Selecting thumbnails needs the user. The grid has no Accessibility elements, and it ignored keys posted while Viewer was in the background. Batch commands act on the selection.

## Batch processing†

File ▸ Export… (`⌘E`) opens Batch Processing for the selected images:

- Images to be processed: Apply each RAW file's own settings (the edits saved by Edit), or Apply the selected image processing settings (a settings file saved by Edit, with View and Browse…).
- Save format, plus Advanced… for bit depth, color space and compression.
- Save in: folder field and Browse….
- File name: Use Original File Name; Date Taken + 5-Digit Number; Date and Time Taken; Specified Name + 5-Digit Number; Specified Name + Date Taken + 5-Digit Number; Specified Name + Date and Time Taken. Characters sets the specified name.
- Cropping: aspect ratio (Do Not Trim, Use the Same Setting as Shooting Settings, or a ratio) and trimming setting (Trim, or Enlarge to Fit Aspect Ratio (With Space)).
- Save or Cancel. Viewer asks before replacing an existing file, and refuses to start if any of the images is open in Edit.

## Other exports†

- File ▸ Export HEIF Format Files…: original color spaces or sRGB, with an option to apply gamma to HLG still images.
- Edit ▸ Apply image process setting…: applies a saved settings file to the selected RAWs.
- Tools ▸ Create Time-lapse Movie: a 4K, Full HD or HD movie from interval shots.

## References

- [Viewer window](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/2_1_viewer_display.php)
- [Selecting and filtering images](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/2_2_rating.php)
- [Remote shooting: Display preview in Viewer](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/4_5_remote.php)
- [Exporting images into JPEG or TIFF](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/5_2_development.php)
- [Saving and applying image-processing settings](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/5_3_save_adjustment.php)
- [Images supported by Imaging Edge Desktop: HEIF files](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/1_3_support_img.php#1_3_HEIF)
- [Creating time-lapse movies](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/2_3_timelapse.php)
- [Keyboard shortcuts](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/6_3_keyboard_shortcuts.php)
