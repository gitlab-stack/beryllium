// beryllium - turn websites into apps on your homescreen
// main app entry point

import SwiftUI

@main
struct BerylliumApp: App {
    @StateObject private var siteStore = SiteStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(siteStore)
                .handleBerylliumURLs()
        }
    }
}
