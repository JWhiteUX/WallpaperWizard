import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    // Must be static — NSApplication.delegate is weak
    static let instance = AppDelegate()

    private var wallpaperManager: WallpaperManager!
    private var statusBarController: StatusBarController!

    static func main() {
        let app = NSApplication.shared
        app.delegate = instance
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[WW] applicationDidFinishLaunching")
        wallpaperManager = WallpaperManager()
        statusBarController = StatusBarController(manager: wallpaperManager)
        wallpaperManager.restoreVideos()
        print("[WW] Ready — look for menu bar icon")
    }
}
