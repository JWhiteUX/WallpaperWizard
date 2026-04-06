# WallpaperWizard

A lightweight macOS menu bar app that plays looping videos as your desktop wallpaper.

<img width="393" height="202" alt="Frame 1" src="https://github.com/user-attachments/assets/37718bbf-3753-4800-9ebf-aae8dc4d0e19" />

## Features

- **Per-display wallpapers** — set a different video for each connected monitor
- **Looping playback** — videos loop seamlessly using `AVQueuePlayer`
- **Remembers your selection** — persists video choices across launches using security-scoped bookmarks
- **Global controls** — play/pause all wallpapers from the menu bar
- **Launch at login** — optional auto-start via `ServiceManagement`
- **Minimal footprint** — no dock icon, lives entirely in the menu bar

## Supported Formats

MP4, MOV, QuickTime, WebM

## Requirements

- macOS 13.0+
- Xcode 14+

## Building

1. Open `WallpaperWizard.xcodeproj` in Xcode
2. Build and run (⌘R)

## Usage

1. Click the ✦ icon in the menu bar
2. Select a display, then choose **Select Video…**
3. Pick a video file — it starts playing as your wallpaper immediately
4. Use **Pause All / Play All** to toggle playback
5. Use **Clear Video** to remove a wallpaper from a display

## Architecture

```
WallpaperWizard/
├── App/
│   └── AppDelegate.swift          # App entry point
├── Playback/
│   ├── VideoPlayer.swift          # AVQueuePlayer looping wrapper
│   └── VideoFileManager.swift     # File picker & bookmark persistence
├── UI/
│   └── StatusBarController.swift  # Menu bar icon & menus
├── Utilities/
│   ├── Defaults.swift             # UserDefaults storage
│   └── LaunchAtLogin.swift        # ServiceManagement wrapper
└── Wallpaper/
    ├── WallpaperManager.swift     # Per-screen video lifecycle
    └── WallpaperWindow.swift      # Borderless desktop-level window
```

## License

MIT
