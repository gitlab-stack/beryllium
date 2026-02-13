// url scheme handler - handles beryllium:// urls for opening sites from shortcuts

import SwiftUI

// handles deep links in the format: beryllium://open?id=<uuid>
struct URLSchemeModifier: ViewModifier {
    @EnvironmentObject var siteStore: SiteStore
    @State private var deepLinkedSite: WebSite?

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                handleURL(url)
            }
            .fullScreenCover(item: $deepLinkedSite) { site in
                WebContainerView(site: site)
            }
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "beryllium",
              url.host == "open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let idString = components.queryItems?.first(where: { $0.name == "id" })?.value,
              let uuid = UUID(uuidString: idString),
              let site = siteStore.sites.first(where: { $0.id == uuid }) else {
            return
        }
        deepLinkedSite = site
    }
}

extension View {
    // convenience modifier to attach the url scheme handler
    func handleBerylliumURLs() -> some View {
        modifier(URLSchemeModifier())
    }
}
