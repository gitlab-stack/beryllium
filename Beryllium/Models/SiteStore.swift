// site store - persists website configurations to disk using json

import Foundation
import SwiftUI

class SiteStore: ObservableObject {
    @Published var sites: [WebSite] = []

    // file path for persisting sites
    private var savePath: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("beryllium_sites.json")
    }

    init() {
        load()
    }

    // load sites from disk
    func load() {
        guard let data = try? Data(contentsOf: savePath),
              let decoded = try? JSONDecoder().decode([WebSite].self, from: data) else {
            return
        }
        sites = decoded
    }

    // save sites to disk
    func save() {
        guard let data = try? JSONEncoder().encode(sites) else { return }
        try? data.write(to: savePath, options: [.atomic, .completeFileProtection])
    }

    // add a new site and persist
    func add(_ site: WebSite) {
        sites.append(site)
        save()
    }

    // update an existing site by id
    func update(_ site: WebSite) {
        if let index = sites.firstIndex(where: { $0.id == site.id }) {
            sites[index] = site
            save()
        }
    }

    // remove sites at the given offsets
    func remove(at offsets: IndexSet) {
        sites.remove(atOffsets: offsets)
        save()
    }

    // fetch the favicon for a site and store it as the icon
    func fetchFavicon(for siteID: UUID) async {
        guard let index = sites.firstIndex(where: { $0.id == siteID }),
              let siteURL = sites[index].url,
              let host = siteURL.host else { return }

        // try common favicon paths in order of quality
        let candidates = [
            "https://\(host)/apple-touch-icon.png",
            "https://\(host)/apple-touch-icon-precomposed.png",
            "https://\(host)/favicon-192x192.png",
            "https://\(host)/favicon-128x128.png",
            "https://\(host)/favicon.ico",
            "https://www.google.com/s2/favicons?domain=\(host)&sz=128"
        ]

        for candidate in candidates {
            guard let url = URL(string: candidate) else { continue }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   UIImage(data: data) != nil {
                    await MainActor.run {
                        sites[index].iconSource = .customImage(data)
                        save()
                    }
                    return
                }
            } catch {
                continue
            }
        }
    }
}
