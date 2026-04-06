import AppKit

final class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let manager: WallpaperManager

    init(manager: WallpaperManager) {
        self.manager = manager
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        super.init()

        if let button = statusItem.button {
            let symbolName = if #available(macOS 14, *) { "sparkles.tv" } else { "tv" }
            if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: "WallpaperWizard") {
                img.isTemplate = true
                button.image = img
            } else {
                button.title = "WW"
            }
        }

        menu.delegate = self
        statusItem.menu = menu
    }

    // MARK: - NSMenuDelegate

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        // Per-screen video selection
        let screens = NSScreen.screens
        for (index, screen) in screens.enumerated() {
            let displayID = screen.displayID
            let screenName = screens.count > 1 ? screen.displayName : "Display"

            let screenItem = NSMenuItem(title: screenName, action: nil, keyEquivalent: "")
            let screenMenu = NSMenu()

            let selectItem = NSMenuItem(title: "Select Video…", action: #selector(selectVideoForScreen(_:)), keyEquivalent: "")
            selectItem.target = self
            selectItem.tag = Int(displayID)
            screenMenu.addItem(selectItem)

            if manager.hasVideo(for: displayID) {
                let clearItem = NSMenuItem(title: "Clear Video", action: #selector(clearVideoForScreen(_:)), keyEquivalent: "")
                clearItem.target = self
                clearItem.tag = Int(displayID)
                screenMenu.addItem(clearItem)
            } else {
                let noneItem = NSMenuItem(title: "No video set", action: nil, keyEquivalent: "")
                noneItem.isEnabled = false
                screenMenu.addItem(noneItem)
            }

            screenItem.submenu = screenMenu
            menu.addItem(screenItem)
        }

        menu.addItem(.separator())

        // Global play/pause
        let playPauseTitle = manager.isAnyPlaying ? "Pause All" : "Play All"
        let playPauseItem = NSMenuItem(title: playPauseTitle, action: #selector(togglePlayPause), keyEquivalent: "")
        playPauseItem.target = self
        playPauseItem.isEnabled = !manager.allPlayers.isEmpty
        menu.addItem(playPauseItem)

        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit WallpaperWizard", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    // MARK: - Actions

    @objc private func selectVideoForScreen(_ sender: NSMenuItem) {
        let displayID = CGDirectDisplayID(sender.tag)
        VideoFileManager.selectVideo { [weak self] url in
            guard let self, let url else { return }
            self.manager.loadVideo(url: url, for: displayID)
        }
    }

    @objc private func clearVideoForScreen(_ sender: NSMenuItem) {
        let displayID = CGDirectDisplayID(sender.tag)
        manager.clearVideo(for: displayID)
    }

    @objc private func togglePlayPause() {
        manager.togglePlayPauseAll()
    }

@objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.toggle()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
