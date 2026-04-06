import AppKit

extension NSScreen {
    var displayID: CGDirectDisplayID {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID) ?? 0
    }

    var displayName: String {
        localizedName
    }
}

struct ScreenEntry {
    let window: WallpaperWindow
    let player: VideoPlayer
}

final class WallpaperManager {
    private var entries: [CGDirectDisplayID: ScreenEntry] = [:]

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    // MARK: - Per-screen video management

    func loadVideo(url: URL, for displayID: CGDirectDisplayID) {
        guard let screen = NSScreen.screens.first(where: { $0.displayID == displayID }) else { return }

        // Remove existing entry for this screen if any
        removeEntry(for: displayID)

        let player = VideoPlayer()
        let window = WallpaperWindow(screen: screen, player: player.player)
        entries[displayID] = ScreenEntry(window: window, player: player)

        player.load(url: url)
        VideoFileManager.saveBookmark(for: url, displayID: displayID)
    }

    func clearVideo(for displayID: CGDirectDisplayID) {
        removeEntry(for: displayID)
        VideoFileManager.clearBookmark(for: displayID)
    }

    func hasVideo(for displayID: CGDirectDisplayID) -> Bool {
        entries[displayID] != nil
    }

    func player(for displayID: CGDirectDisplayID) -> VideoPlayer? {
        entries[displayID]?.player
    }

    // MARK: - Global controls

    var allPlayers: [VideoPlayer] {
        Array(entries.values.map(\.player))
    }

    var isAnyPlaying: Bool {
        allPlayers.contains(where: \.isPlaying)
    }

    func togglePlayPauseAll() {
        let shouldPause = isAnyPlaying
        for player in allPlayers {
            if shouldPause { player.player.pause() }
            else { player.player.play() }
        }
    }


    // MARK: - Restore on launch

    func restoreVideos() {
        for screen in NSScreen.screens {
            let id = screen.displayID
            if let url = VideoFileManager.restoreBookmarkedURL(for: id) {
                let player = VideoPlayer()
                let window = WallpaperWindow(screen: screen, player: player.player)
                entries[id] = ScreenEntry(window: window, player: player)
                player.load(url: url)
            }
        }
    }

    // MARK: - Screen changes

    @objc private func screenParametersChanged() {
        let currentScreens = NSScreen.screens
        let currentIDs = Set(currentScreens.map(\.displayID))
        let existingIDs = Set(entries.keys)

        // Remove entries for disconnected screens
        for id in existingIDs.subtracting(currentIDs) {
            removeEntry(for: id)
        }

        // Update frames for existing screens
        for screen in currentScreens {
            entries[screen.displayID]?.window.updateFrame(for: screen)
        }
    }

    private func removeEntry(for displayID: CGDirectDisplayID) {
        if let entry = entries.removeValue(forKey: displayID) {
            entry.window.close()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
