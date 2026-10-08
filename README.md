# Herdr Photo Picker

A Windows-only Herdr plugin that opens the native file picker and inserts the selected image paths into the focused agent pane's input. It does not submit the input, so you can add your own prompt first.

## Requirements

- Windows
- Herdr 0.9.0 or newer
- An agent in the focused pane that can access and inspect the selected files

## Install

```powershell
herdr plugin install nnabilsayed/herdr-photo-picker
```

## Use

1. Focus the pane with the agent you want to use.
2. Press **Ctrl+B**, then **Shift+I**.
3. Choose one or more images in the file picker.
4. The quoted file paths appear in the agent's input. Add your question or instruction, then press Enter when ready.

You can also invoke the action from a PowerShell terminal:

```powershell
herdr plugin action invoke nabil.photo-picker.pick-photo
```

## Key binding

The plugin action can be invoked from Herdr's keybindings. Add this to your Herdr `config.toml` if it is not already present:

```toml
[[keys.command]]
key = "prefix+shift+i"
type = "plugin_action"
command = "nabil.photo-picker.pick-photo"
description = "Pick photo for active agent"
```

Herdr's default prefix is **Ctrl+B**. If you use a different prefix or prefer another shortcut, change the `key` value.

## Supported image filters

JPG/JPEG, PNG, GIF, BMP, WebP, HEIC/HEIF, and TIFF.

## File handling

The plugin inserts quoted absolute paths as text. It does not upload, copy, or modify the selected files, and it does not send the prompt. The agent needs filesystem access to those paths; a remote agent may not be able to access a path on your Windows machine. Whether HEIC is readable depends on the agent.

## Local development

```powershell
herdr plugin link 'E:\herdr-photo-picker'
herdr plugin action list --plugin nabil.photo-picker
```
## License

This project is licensed under the [MIT License](LICENSE).
