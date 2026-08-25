import UIKit

/// Runs a user-authored Shortcuts app automation by name.
///
/// iOS has no public API for a third-party app to control another app's media
/// playback (e.g. system-wide play/pause), so this delegates to the Shortcuts
/// app instead — it has that capability built in, and the user wires it up by
/// creating a shortcut (e.g. named "Play/Pause") that Clickflow then triggers.
///
/// Running a shortcut backgrounds Clickflow, which stops volume-button
/// monitoring. The x-success/x-cancel/x-error callbacks below tell Shortcuts
/// to switch straight back to Clickflow (via its own "clickflow://" URL
/// scheme) as soon as the automation finishes, instead of leaving Shortcuts
/// in the foreground.
enum ShortcutRunner {
    @MainActor
    static func run(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let encodedName = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        let returnURL = "clickflow://shortcut-completed"
        guard let encodedReturn = returnURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        let urlString = "shortcuts://x-callback-url/run-shortcut"
            + "?name=\(encodedName)"
            + "&x-success=\(encodedReturn)"
            + "&x-cancel=\(encodedReturn)"
            + "&x-error=\(encodedReturn)"

        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
