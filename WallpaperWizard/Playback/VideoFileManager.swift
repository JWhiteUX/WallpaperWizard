import AppKit
import UniformTypeIdentifiers

enum VideoFileManager {
    static func selectVideo(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = supportedTypes()
        panel.message = "Choose a video file for your wallpaper"

        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                completion(nil)
                return
            }
            completion(url)
        }
    }

    static func saveBookmark(for url: URL, displayID: UInt32) {
        do {
            let data = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            Defaults.setVideoBookmarkData(data, for: displayID)
        } catch {
            print("Failed to save bookmark: \(error)")
        }
    }

    static func restoreBookmarkedURL(for displayID: UInt32) -> URL? {
        guard let data = Defaults.videoBookmarkData(for: displayID) else { return nil }

        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            if isStale {
                saveBookmark(for: url, displayID: displayID)
            }
            return url
        } catch {
            print("Failed to restore bookmark for display \(displayID): \(error)")
            return nil
        }
    }

    static func clearBookmark(for displayID: UInt32) {
        Defaults.setVideoBookmarkData(nil, for: displayID)
    }

    private static func supportedTypes() -> [UTType] {
        var types: [UTType] = [.mpeg4Movie, .quickTimeMovie, .movie]
        if let webm = UTType(filenameExtension: "webm") {
            types.append(webm)
        }
        return types
    }
}
