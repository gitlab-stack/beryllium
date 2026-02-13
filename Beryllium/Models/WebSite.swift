// website model - stores configuration for each wrapped site

import Foundation

// orientation lock options for the web container
enum OrientationLock: String, Codable, CaseIterable, Identifiable {
    case automatic = "automatic"
    case portrait = "portrait"
    case landscape = "landscape"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

// represents a single website configured to run as an app
struct WebSite: Identifiable, Codable {
    var id: UUID
    var name: String
    var urlString: String
    var orientationLock: OrientationLock
    var enableJavaScript: Bool
    var enableStikJIT: Bool
    var allowInlineMedia: Bool
    var enableFullScreen: Bool
    var userAgent: String
    var iconColorHex: String

    // default configuration for a new site
    init(
        id: UUID = UUID(),
        name: String = "",
        urlString: String = "https://",
        orientationLock: OrientationLock = .automatic,
        enableJavaScript: Bool = true,
        enableStikJIT: Bool = false,
        allowInlineMedia: Bool = true,
        enableFullScreen: Bool = false,
        userAgent: String = "",
        iconColorHex: String = "007AFF"
    ) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.orientationLock = orientationLock
        self.enableJavaScript = enableJavaScript
        self.enableStikJIT = enableStikJIT
        self.allowInlineMedia = allowInlineMedia
        self.enableFullScreen = enableFullScreen
        self.userAgent = userAgent
        self.iconColorHex = iconColorHex
    }

    // build a url from the stored string, returns nil if invalid
    var url: URL? {
        URL(string: urlString)
    }
}
