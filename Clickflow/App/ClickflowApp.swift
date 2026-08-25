import SwiftUI

@main
struct ClickflowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL { _ in
                    // The Shortcuts app calls back through "clickflow://shortcut-completed"
                    // purely to bring Clickflow back to the foreground; no payload to handle.
                }
        }
    }
}
