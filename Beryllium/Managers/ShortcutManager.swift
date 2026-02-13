// shortcut manager - generates a web clip profile or shortcuts integration
// for adding wrapped sites to the ios home screen

import Foundation
import UIKit

struct ShortcutManager {
    // generate an html data url that creates a home screen bookmark
    // this works by hosting a tiny page that uses a meta tag redirect
    // the user can then use "add to home screen" from the share sheet
    static func generateShortcutPage(for site: WebSite) -> URL? {
        // build a minimal html page that redirects into beryllium via url scheme
        let appURL = "beryllium://open?id=\(site.id.uuidString)"
        let html = """
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-title" content="\(site.name)">
        <title>\(site.name)</title>
        <style>
        body {
            font-family: -apple-system, sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background: #000;
            color: #fff;
        }
        </style>
        <script>
        window.location.href = "\(appURL)";
        </script>
        </head>
        <body>
        <p>opening \(site.name) in beryllium...</p>
        </body>
        </html>
        """

        // write the html to a temporary file for sharing
        let tempDir = FileManager.default.temporaryDirectory
        let filePath = tempDir.appendingPathComponent("\(site.name.lowercased().replacingOccurrences(of: " ", with: "-"))-shortcut.html")
        try? html.data(using: .utf8)?.write(to: filePath)
        return filePath
    }

    // generate a shortcuts app url to create an "open app" shortcut
    static func shortcutsAppURL(for site: WebSite) -> URL? {
        let appURL = "beryllium://open?id=\(site.id.uuidString)"
        // this opens the shortcuts app with a pre-filled "open url" action
        return URL(string: "shortcuts://create-shortcut?name=\(site.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? site.name)&url=\(appURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? appURL)")
    }
}
