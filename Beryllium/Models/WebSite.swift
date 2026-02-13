// website model - stores configuration for each wrapped site

import Foundation
import UIKit

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

// how the site icon is sourced
enum IconSource: Codable, Equatable {
    case colorLetter                // default: colored square with first letter
    case customImage(Data)          // user-picked image from photo library
    case favicon                    // auto-fetched from the site's favicon

    // coding keys for the tagged enum
    private enum CodingKeys: String, CodingKey {
        case type, imageData
    }

    private enum IconType: String, Codable {
        case colorLetter, customImage, favicon
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(IconType.self, forKey: .type)
        switch type {
        case .colorLetter:
            self = .colorLetter
        case .customImage:
            let data = try container.decode(Data.self, forKey: .imageData)
            self = .customImage(data)
        case .favicon:
            self = .favicon
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .colorLetter:
            try container.encode(IconType.colorLetter, forKey: .type)
        case .customImage(let data):
            try container.encode(IconType.customImage, forKey: .type)
            try container.encode(data, forKey: .imageData)
        case .favicon:
            try container.encode(IconType.favicon, forKey: .type)
        }
    }

    // convert stored data back to a uiimage
    var uiImage: UIImage? {
        if case .customImage(let data) = self {
            return UIImage(data: data)
        }
        return nil
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
    var iconSource: IconSource

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
        iconColorHex: String = "007AFF",
        iconSource: IconSource = .colorLetter
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
        self.iconSource = iconSource
    }

    // build a url from the stored string, returns nil if invalid
    var url: URL? {
        URL(string: urlString)
    }
}
