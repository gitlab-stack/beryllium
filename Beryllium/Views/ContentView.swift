// content view - main screen showing the list of configured websites

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var siteStore: SiteStore
    @State private var showingAddSite = false
    @State private var selectedSite: WebSite?

    var body: some View {
        NavigationStack {
            Group {
                if siteStore.sites.isEmpty {
                    // empty state when no sites have been added yet
                    VStack(spacing: 16) {
                        Image(systemName: "globe")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary)
                        Text("no websites yet")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("tap + to wrap a website into an app")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(siteStore.sites) { site in
                            SiteRow(site: site)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedSite = site
                                }
                        }
                        .onDelete(perform: siteStore.remove)
                    }
                }
            }
            .navigationTitle("beryllium")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSite = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSite) {
                SiteEditorView(mode: .add)
                    .environmentObject(siteStore)
            }
            .fullScreenCover(item: $selectedSite) { site in
                WebContainerView(site: site)
            }
        }
    }
}

// row view for a single site in the list
struct SiteRow: View {
    let site: WebSite

    var body: some View {
        HStack(spacing: 12) {
            // colored icon circle with first letter of the site name
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: site.iconColorHex) ?? .blue)
                    .frame(width: 48, height: 48)
                Text(String(site.name.prefix(1)).uppercased())
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)
                Text(site.urlString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // orientation indicator
            Image(systemName: orientationIcon)
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }

    private var orientationIcon: String {
        switch site.orientationLock {
        case .portrait: return "iphone"
        case .landscape: return "iphone.landscape"
        case .automatic: return "arrow.triangle.2.circlepath"
        }
    }
}

// hex color extension for the icon colors
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b)
    }
}
