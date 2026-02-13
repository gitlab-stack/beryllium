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
            // site icon - either custom image or colored letter fallback
            SiteIconView(site: site, size: 48)

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

// reusable icon view that renders the correct icon type for a site
struct SiteIconView: View {
    let site: WebSite
    let size: CGFloat

    var body: some View {
        Group {
            if let image = site.iconSource.uiImage {
                // custom or favicon image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
            } else {
                // fallback: colored square with first letter
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .fill(Color(hex: site.iconColorHex) ?? .blue)
                        .frame(width: size, height: size)
                    Text(String(site.name.prefix(1)).uppercased())
                        .font(.system(size: size * 0.45, weight: .bold))
                        .foregroundColor(.white)
                }
            }
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
