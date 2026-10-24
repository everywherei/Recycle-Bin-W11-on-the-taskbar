# RecycleBinTray

[English](README.md) · [Español](README.es.md)

A tiny PowerShell script for Windows 10/11 that puts the **Recycle Bin in the system tray** and **removes it from the desktop**, so it stops cluttering your folders and files.

No compiler, no dependencies, no admin rights required.

## Features

- Recycle Bin icon in the system tray, using the official Windows icon (empty / full), sharp on high-DPI screens
- Hides the Recycle Bin icon from the desktop
- Tooltip with the number of items in the bin
- **Left click**: open the Recycle Bin
- **Middle click**: empty the Recycle Bin
- **Right click**: menu with *Open*, *Empty Recycle Bin*, *Properties* and *Exit*
- *Empty Recycle Bin* is disabled while the bin is empty
- Starts automatically with Windows, without showing any PowerShell window
- Localized in the language of Windows: English, Spanish, Chinese (Simplified and Traditional), Portuguese, Russian, German, French, Japanese, Italian and Korean (falls back to English)

## Install

1. Download `RecycleBinTray.ps1`.
2. Open PowerShell in the folder where you saved it and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\RecycleBinTray.ps1
   ```

The script copies itself to `%LOCALAPPDATA%\RecycleBinTray`, registers itself to start with Windows (current user only) and launches immediately. You can delete the downloaded file afterwards.

> Windows 11 usually places new tray icons in the overflow menu (`^`). Drag the icon onto the taskbar to keep it always visible.

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File .\RecycleBinTray.ps1 -Uninstall
```

This stops the program, removes the startup entry and its files, and shows the Recycle Bin on the desktop again.

## How it works

- **Desktop icon:** sets the `{645FF040-5081-101B-9F08-00AA002F954E}` value to `1` under `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons` (`NewStartPanel` and `ClassicStartMenu`) and refreshes the desktop.
- **Tray icon:** a Windows Forms `NotifyIcon`. Icons come from `SHGetStockIconInfo`, with `shell32.dll` resources as fallback. The item count is checked every 1.5 seconds.
- **Startup:** a `Run` entry in `HKCU` launches a small `.vbs` file, which starts PowerShell with no visible window.
- Everything is per-user. Nothing is written outside `HKCU` and `%LOCALAPPDATA%\RecycleBinTray`.

## Notes

- If your Windows version already shows its own Recycle Bin icon in the taskbar, this script does not change it; it adds its own icon to the tray.
- Dropping files onto a tray icon is not supported by Windows, so drag and drop is not available.
- Execution policy: the commands above use `-ExecutionPolicy Bypass` for that single run only; your system policy is not changed.

## Credits

Created by [everywherei](https://github.com/everywherei). Inspired by [Compactor](https://github.com/BrandonXLF/compactor) by BrandonXLF (MIT).

## License

[MIT](LICENSE)
