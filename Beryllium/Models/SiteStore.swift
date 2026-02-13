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
}
