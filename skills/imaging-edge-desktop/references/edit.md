# Edit

Controls for developing and exporting. Viewing aids are omitted: zoom, double view, clipping display, histogram, navigator and image properties. Items marked † come from the app's resources and were not opened.

## Images

- Open files with `open -g -b com.sony.Edit <files>`, or with File ▸ Open… (`⌘O`). Edit opens ARW, ARQ, AXR, SR2, JPEG, TIFF and HEIF; JPEG, TIFF and HEIF get only a few adjustments.
- Each image is a tab: a static text with the file name, prefixed with `*` while there are unsaved edits, and a close button with help `Close '<file>.'`. File ▸ Previous Image and Next Image switch tabs.
- Undo and Redo are in the Edit menu. Rotate Counterclockwise and Rotate Clockwise are in the Edit menu and on the toolbar.
- Save (`⌘S`) writes the adjustments into the RAW file as its current version, keeping the As Shot Version.
- Cropping and Inclination Correction (toolbar or Edit menu)†: aspect ratio including Custom, width and height, inclination angle, Apply Camera setting, Close.

## Palettes

The right sidebar's palettes are flattened into one scroll area, and their titles are not exposed. A value row has a static-text label, then a `-` button, a slider, a `+` button and a value field, about 20 px below the label. Match a label with `ax find`, then pick the field or slider nearest below it by position. Mode choices are checkboxes titled with the choice; pressing one selects it.

| Palette | Labels and choices |
| --- | --- |
| Brightness | EV field (`+0.00EV`); Reset |
| White Balance | Camera setting, Preset (popup), Color temperature (field in K, plus a ± K fine-tune for presets), Specify gray point; Color correction; Reset |
| Creative Look | popup: Camera setting, ST, PT, NT, VV, VV2, FL, IN, SH, BW, SE |
| Contrast | Contrast, Highlights, Shadows, Whites, Blacks, Fade; Reset |
| D-Range Optimizer | Off, Auto, Manual; Amount (Manual only); Reset |
| Highlight color distortion reduction | Standard, Advanced |
| Color | Hue, Saturation; a Reset for each |
| Shading Compensation | Central radius, Central strength, Peripheral strength; Reset |
| Sharpness | Amount, Overshoot, Undershoot, Threshold, Sharpness Range; Reset. Clarity; Reset |
| Noise Reduction | Off, Auto, Manual; Amount, Color noise reduction, Edge noise reduction (Manual only); Reset |
| Lens Correction | Distortion Compensation On or Off; Magnification Chromatic Aberration Correction On or Off |
| Tone Curve | channel popup (Y, R, G, B); Reset, Reset All. The curve itself can't be edited through Accessibility. |

- Changing Creative Look asks for confirmation and resets all other settings, so set it first.
- A collapsed palette keeps stale positions; expand it with the checkbox at the left of its header row.
- Version Stack, below the palettes: Create New Version, Set to Current Version, and a list of versions such as As Shot Version and Current Version.

## Settings reuse

Edit ▸ Image Processing Settings:

- Copy (`⌘C`) and Paste (`⌘V`) carry all adjustments to another open image.
- Save… stores the current palette values under a name, for Load and Apply Settings… or Viewer's batch processing.
- Load and Apply Settings… applies a saved settings file to the current image.

## Output

File ▸ Output… (`⌘E`), or the toolbar's Output button, exports the current image without changing the RAW:

| Control | Values |
| --- | --- |
| Save As | file name field |
| Where | folder popup; it shows the folder's name, not its path |
| File format | JPEG Files, TIFF Files |
| Compression | Compression Level 1 (high quality) to 4 (high compression) |
| Color space | Working Color Space, sRGB, AdobeRGB, Wide Gamut RGB |
| 8 bit / 16 bit | radio buttons, disabled for JPEG |
| Width, Height | fields, with the aspect ratio locked |
| Save, Cancel | buttons |

Give the file a unique name and save it to the folder shown. Then find the file, for example with `mdfind -name <file>`, and move it from the shell. The working color space is set under View ▸ Working Color Space.

## References

- [Images supported by Imaging Edge Desktop](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/1_3_support_img.php)
- [Edit window](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/3_1_retouch_display.php)
- [Adjusting images](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/3_3_retouching.php)
- [Saving images as RAW data](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/5_1_save_as_raw.php)
- [Exporting images into JPEG or TIFF](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/5_2_development.php)
- [Saving and applying image-processing settings](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/5_3_save_adjustment.php)
- [Keyboard shortcuts](https://support.d-imaging.sony.co.jp/app/imagingedge/en/instruction/6_3_keyboard_shortcuts.php)
