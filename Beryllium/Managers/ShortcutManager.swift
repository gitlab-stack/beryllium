// shortcut manager - generates the html page used for home screen shortcuts.
// the page has two modes:
//   1. opened in safari: shows step-by-step "add to home screen" instructions
//   2. opened from home screen (standalone): immediately redirects to beryllium

import Foundation
import UIKit

struct ShortcutManager {
    /// generate the html page that safari serves for "add to home screen".
    /// uses apple-mobile-web-app-capable so the web clip opens in standalone
    /// mode and the js redirect fires on subsequent launches.
    static func generateShortcutHTML(for site: WebSite) -> String {
        let appURL = "beryllium://open?id=\(site.id.uuidString)"

        let escapedName = site.name
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "\"", with: "&quot;")

        let escapedURL = site.urlString
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")

        // encode site icon as base64 for the apple-touch-icon so the home
        // screen shortcut gets the correct icon
        var iconLink = ""
        if let image = site.iconSource.uiImage,
           let pngData = image.pngData() {
            let base64 = pngData.base64EncodedString()
            iconLink = """
            <link rel="apple-touch-icon" href="data:image/png;base64,\(base64)">
            """
        }

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
        <meta name="apple-mobile-web-app-title" content="\(escapedName)">
        \(iconLink)
        <title>\(escapedName)</title>
        <style>
        *{margin:0;padding:0;box-sizing:border-box}
        body{
            font-family:-apple-system,BlinkMacSystemFont,sans-serif;
            background:#000;color:#fff;
            min-height:100vh;min-height:100dvh;
            display:flex;flex-direction:column;
            align-items:center;justify-content:center;
            padding:32px 24px;text-align:center;
            -webkit-user-select:none;user-select:none;
        }
        h1{font-size:22px;font-weight:700;margin-bottom:6px}
        .url{font-size:13px;color:#888;margin-bottom:36px;word-break:break-all}
        .steps{text-align:left;max-width:300px;margin-bottom:32px}
        .step{display:flex;align-items:flex-start;gap:12px;margin-bottom:20px}
        .num{
            background:#007AFF;width:26px;height:26px;border-radius:13px;
            display:flex;align-items:center;justify-content:center;
            font-weight:700;font-size:13px;flex-shrink:0;
        }
        .txt{font-size:15px;line-height:1.5;padding-top:1px}
        .share-icon{display:inline-block;width:18px;height:18px;vertical-align:-3px;margin:0 2px}
        .btn{
            display:inline-block;background:#007AFF;color:#fff;
            border:none;padding:13px 28px;border-radius:12px;
            font-size:16px;font-weight:600;text-decoration:none;
        }
        .loading{display:none;flex-direction:column;align-items:center;justify-content:center;height:100vh;gap:16px}
        .loading.active{display:flex}
        .content.hidden{display:none}
        .spinner{
            width:32px;height:32px;border:3px solid #333;
            border-top-color:#007AFF;border-radius:50%;
            animation:spin .8s linear infinite;
        }
        @keyframes spin{to{transform:rotate(360deg)}}
        </style>
        <script>
        // if launched from home screen (standalone mode), redirect into beryllium
        if(window.navigator.standalone){
            document.addEventListener('DOMContentLoaded',function(){
                document.querySelector('.content').classList.add('hidden');
                document.querySelector('.loading').classList.add('active');
                window.location.href="\(appURL)";
            });
        }
        </script>
        </head>
        <body>
        <div class="loading">
            <div class="spinner"></div>
            <p>opening \(escapedName)...</p>
        </div>
        <div class="content">
            <h1>\(escapedName)</h1>
            <div class="url">\(escapedURL)</div>
            <div class="steps">
                <div class="step">
                    <div class="num">1</div>
                    <div class="txt">Tap the <strong>Share</strong> button
                        <svg class="share-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/>
                            <polyline points="16,6 12,2 8,6"/>
                            <line x1="12" y1="2" x2="12" y2="15"/>
                        </svg>
                        at the bottom of Safari
                    </div>
                </div>
                <div class="step">
                    <div class="num">2</div>
                    <div class="txt">Scroll down and tap <strong>"Add to Home Screen"</strong></div>
                </div>
                <div class="step">
                    <div class="num">3</div>
                    <div class="txt">Tap <strong>"Add"</strong> — done!</div>
                </div>
            </div>
            <a class="btn" href="\(appURL)">open in beryllium</a>
        </div>
        </body>
        </html>
        """
    }
}
