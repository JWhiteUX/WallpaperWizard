import AVFoundation

final class VideoPlayer {
    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var currentURL: URL?
    private var accessingSecurityScope = false

    func load(url: URL) {
        stopAccessingSecurityScope()

        if url.startAccessingSecurityScopedResource() {
            accessingSecurityScope = true
        }

        let item = AVPlayerItem(url: url)
        looper = AVPlayerLooper(player: player, templateItem: item)
        currentURL = url
        player.play()
    }

    var isPlaying: Bool {
        player.rate > 0
    }

    private func stopAccessingSecurityScope() {
        if accessingSecurityScope, let url = currentURL {
            url.stopAccessingSecurityScopedResource()
            accessingSecurityScope = false
        }
    }

    deinit {
        stopAccessingSecurityScope()
    }
}
