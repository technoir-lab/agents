# Automation

## Helper commands

| Command | Use |
| --- | --- |
| `ax trusted` | Check Accessibility access. When it is missing, names the binary to grant. |
| `ax tree <app> [windows\|menubar\|all] [depth]` | Print elements with their paths. Defaults to windows. |
| `ax find <app> <text>` | Elements whose title, value, description, help or identifier contains the text, case-insensitive. |
| `ax info <app> <path>` | One element. |
| `ax press <app> <path>` | Press a button, checkbox, tab, popup or menu item. |
| `ax action <app> <path> <AXAction>` | Other actions: `AXCancel`, `AXConfirm`, `AXIncrement`, `AXDecrement`. |
| `ax set <app> <path> <value>` | Set a value field's text, or a slider's number. |
| `ax setattr <app> <path> <attribute> <value>` | Set any attribute, e.g. `AXMinimized false` or `AXSelected true`. |
| `ax key <app> <key> [cmd] [shift] [ctrl] [opt]` | Post a key to the app's process: `esc`, `return`, `tab`, `a`–`z`, `0`–`9`, arrows. |
| `ax click <app> <x> <y>` | Post a left click to the app's process at screen coordinates. |

`<app>` is `Remote`, `Edit`, `Viewer` or a pid. A path is `w<N>` for window N or `mb` for the menu bar, followed by child indices, e.g. `w0.27.5` or `mb.3.0.0.0.1`. Output lines show role, title, value, description (`desc`), help, identifier, menu shortcut (`key`), check mark, `DISABLED`, global position and size (`@x,y wxh`, top-left origin, the same coordinates `click` takes), and available actions.

## Behaviour

- **Modal dialogs**: a press that opens a dialog returns `ok` or `cannotComplete`. Either way, read the tree again. The dialog becomes `w0` and the main window moves to `w1`.
- **Menus**: menu items can be pressed without opening the menu. The tree's enabled flags can be stale until the menu has been opened on screen, so try the press and check its effect. Submenus that list camera values may be filled in only when they are opened.
- **Popup buttons**: a press opens the menu, whose items appear as the popup's children (`<path>.0.<n>`). Press an item, or close the menu with `ax key <app> esc`.
- **Popovers**, such as Remote's grid and guide options, close with `ax action <app> <popover> AXCancel`.
- **Remote value pickers**: pressing a Main Settings value opens a borderless window titled `Window` with a table of values. Its rows have no actions. Close it by clicking outside, e.g. `ax click Remote <x> <y>` on the main window's title bar between the window buttons and the title. Use the ± menu items to change values instead.
- **Remote sub-setting pickers**: a panel of option buttons, labelled by their help text, plus a Close button (help `Close`).
- **Collapsed sections**: a collapsed Remote panel section or Edit palette keeps no children, or keeps stale positions. Expand it with the button left of its title, and collapse it again afterwards.
- **Value fields**: set the text with `ax set`, then commit it with `ax action ... AXConfirm`. Sliders also take `AXIncrement` and `AXDecrement`. Re-read the field, because the app clamps and rounds values.
- **Background input**: posted Escape closes popup menus, and posted clicks reach Remote's window. Viewer's thumbnail grid ignored posted keys while Viewer was in the background.
- **Minimized windows**: restore with `ax setattr <app> w0 AXMinimized false`, and minimize again when done.
- **Not exposed**: live view, Edit's image and tone curve, Viewer's thumbnails, and Edit's palette titles. Identify palettes by their controls' labels.

## Verified

Exercised with Imaging Edge Desktop 4.1.00 and a connected Sony camera on macOS:

- reading trees, values and menu shortcuts in all three apps
- pressing buttons, tabs and menu items; opening and closing Remote's Settings, Camera Settings, value and sub-setting pickers, and grid and guide popovers
- Edit's Output dialog and its popups, closed with Cancel
- opening a RAW in Edit with `open -g -b com.sony.Edit`, which kept Edit in the background, and closing its tab, which left the file unchanged
- reading the tree from inside the agent's shell sandbox
- selecting a folder in Viewer's tree, and restoring and minimizing its window

Not exercised: shooting, changing camera or palette values, Save, Output's Save, and Viewer's Batch Processing, which is described from the app's resources.
