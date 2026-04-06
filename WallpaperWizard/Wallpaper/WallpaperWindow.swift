import AppKit
import AVFoundation

final class WallpaperWindow: NSWindow {
    private let playerLayer = AVPlayerLayer()

    init(screen: NSScreen, player: AVQueuePlayer) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        isOpaque = true
        hasShadow = false
        ignoresMouseEvents = true
        backgroundColor = .black
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isReleasedWhenClosed = false

        let view = NSView(frame: screen.frame)
        view.wantsLayer = true
        contentView = view

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        view.layer?.addSublayer(playerLayer)

        orderFront(nil)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func updateFrame(for screen: NSScreen) {
        setFrame(screen.frame, display: true)
    }
}
