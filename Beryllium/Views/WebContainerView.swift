// web container view - hosts a wkwebview that wraps the configured website
// this is the core of beryllium: a native container instead of opening safari

import SwiftUI
import WebKit

struct WebContainerView: View {
    let site: WebSite
    @Environment(\.dismiss) private var dismiss
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = true
    @State private var currentURL: String = ""
    @State private var showingEditSheet = false
    @State private var showControls = true

    var body: some View {
        ZStack(alignment: .bottom) {
            // the webview fills the entire screen
            WebView(
                site: site,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                isLoading: $isLoading,
                currentURL: $currentURL
            )
            .ignoresSafeArea(site.enableFullScreen ? .all : .init())

            // floating navigation bar at the bottom
            if showControls {
                HStack(spacing: 24) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }

                    Spacer()

                    Button {
                        NotificationCenter.default.post(name: .webViewGoBack, object: nil)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                    .disabled(!canGoBack)

                    Button {
                        NotificationCenter.default.post(name: .webViewGoForward, object: nil)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                    }
                    .disabled(!canGoForward)

                    Button {
                        NotificationCenter.default.post(name: .webViewReload, object: nil)
                    } label: {
                        Image(systemName: isLoading ? "xmark" : "arrow.clockwise")
                            .font(.title3)
                    }

                    Spacer()

                    Button { showingEditSheet = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .statusBarHidden(site.enableFullScreen)
        .onTapGesture(count: 3) {
            // triple tap toggles the control bar visibility
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls.toggle()
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            SiteEditorView(mode: .edit(site))
        }
        .modifier(OrientationLockModifier(lock: site.orientationLock))
    }
}

// notification names for controlling the webview from swiftui buttons
extension Notification.Name {
    static let webViewGoBack = Notification.Name("webViewGoBack")
    static let webViewGoForward = Notification.Name("webViewGoForward")
    static let webViewReload = Notification.Name("webViewReload")
}

// uiviewrepresentable wrapper around wkwebview
struct WebView: UIViewRepresentable {
    let site: WebSite
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var currentURL: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()

        // configure javascript preference
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = site.enableJavaScript
        config.defaultWebpagePreferences = prefs

        // allow inline media playback (important for video-heavy sites)
        config.allowsInlineMediaPlayback = site.allowInlineMedia
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // set custom user agent if configured
        if !site.userAgent.isEmpty {
            webView.customUserAgent = site.userAgent
        }

        // observe navigation state changes
        context.coordinator.observe(webView)

        // subscribe to navigation control notifications
        context.coordinator.subscribeToControls(webView)

        // load the initial url
        if let url = site.url {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // no dynamic updates needed; the webview manages its own state
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        private var observations: [NSKeyValueObservation] = []
        private var notificationTokens: [Any] = []

        init(_ parent: WebView) {
            self.parent = parent
        }

        deinit {
            observations.removeAll()
            notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
        }

        // kvo on webview properties to update swiftui state
        func observe(_ webView: WKWebView) {
            observations = [
                webView.observe(\.canGoBack) { [weak self] wv, _ in
                    DispatchQueue.main.async { self?.parent.canGoBack = wv.canGoBack }
                },
                webView.observe(\.canGoForward) { [weak self] wv, _ in
                    DispatchQueue.main.async { self?.parent.canGoForward = wv.canGoForward }
                },
                webView.observe(\.isLoading) { [weak self] wv, _ in
                    DispatchQueue.main.async { self?.parent.isLoading = wv.isLoading }
                },
                webView.observe(\.url) { [weak self] wv, _ in
                    DispatchQueue.main.async { self?.parent.currentURL = wv.url?.absoluteString ?? "" }
                }
            ]
        }

        // listen for navigation button taps sent via notificationcenter
        func subscribeToControls(_ webView: WKWebView) {
            notificationTokens = [
                NotificationCenter.default.addObserver(
                    forName: .webViewGoBack, object: nil, queue: .main
                ) { _ in webView.goBack() },
                NotificationCenter.default.addObserver(
                    forName: .webViewGoForward, object: nil, queue: .main
                ) { _ in webView.goForward() },
                NotificationCenter.default.addObserver(
                    forName: .webViewReload, object: nil, queue: .main
                ) { _ in
                    if webView.isLoading { webView.stopLoading() }
                    else { webView.reload() }
                }
            ]
        }

        // handle stikjit url scheme if enabled
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            if let url = navigationAction.request.url,
               parent.site.enableStikJIT,
               url.scheme == "stikjit" {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
                return .cancel
            }
            return .allow
        }
    }
}
