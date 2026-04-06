import Foundation

enum Defaults {
    private enum Key: String {
        case videoBookmarks
    }

    // Per-screen bookmark storage: [displayID string : bookmark Data]
    static func videoBookmarkData(for displayID: UInt32) -> Data? {
        bookmarksDictionary[String(displayID)]
    }

    static func setVideoBookmarkData(_ data: Data?, for displayID: UInt32) {
        var dict = bookmarksDictionary
        dict[String(displayID)] = data
        UserDefaults.standard.set(dict, forKey: Key.videoBookmarks.rawValue)
    }

    static var allVideoBookmarks: [String: Data] {
        bookmarksDictionary
    }

    private static var bookmarksDictionary: [String: Data] {
        (UserDefaults.standard.dictionary(forKey: Key.videoBookmarks.rawValue) as? [String: Data]) ?? [:]
    }

}
