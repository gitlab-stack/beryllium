// orientation lock modifier - forces the webview container to a specific orientation
// uses the uiwindowscene api available in ios 16+

import SwiftUI

struct OrientationLockModifier: ViewModifier {
    let lock: OrientationLock

    func body(content: Content) -> some View {
        content
            .onAppear { applyLock() }
            .onDisappear { releaseLock() }
    }

    // request the system to lock to the configured orientation
    private func applyLock() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        let mask: UIInterfaceOrientationMask
        switch lock {
        case .portrait:
            mask = .portrait
        case .landscape:
            mask = .landscape
        case .automatic:
            mask = .all
        }

        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: mask)
        scene.requestGeometryUpdate(geometryPreferences) { error in
            // geometry update failed, not much we can do here
            print("beryllium: orientation lock error - \(error.localizedDescription)")
        }
    }

    // release the lock when leaving the web container
    private func releaseLock() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .all)
        scene.requestGeometryUpdate(geometryPreferences) { _ in }
    }
}
