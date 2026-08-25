import Foundation
import Observation

/// Shared, persisted source of truth for command presets, so edits made in
/// Settings are actually picked up by the volume-button listener.
@MainActor
@Observable
final class PresetStore {
    static let shared = PresetStore()

    var presets: [CommandPreset] {
        didSet { persistPresets() }
    }

    /// When true, UP and DOWN always run the same shortcut; when false, each is edited independently.
    var isSharedShortcut: Bool {
        didSet {
            persistMode()
            if isSharedShortcut {
                syncDownToUp()
            }
        }
    }

    private let presetsKey = "com.unlimitedxblue.clickflow.presets"
    private let modeKey = "com.unlimitedxblue.clickflow.sharedShortcutMode"

    private init() {
        if let data = UserDefaults.standard.data(forKey: presetsKey),
           let decoded = try? JSONDecoder().decode([CommandPreset].self, from: data) {
            presets = decoded
        } else {
            presets = CommandPreset.defaultPresets
        }
        isSharedShortcut = UserDefaults.standard.bool(forKey: modeKey)
    }

    /// Reads/writes the UP preset's shortcut name; writing also mirrors it onto DOWN.
    var sharedShortcutName: String {
        get { presets.first(where: { $0.button == .up })?.shortcutName ?? "" }
        set {
            for index in presets.indices {
                presets[index].shortcutName = newValue
            }
        }
    }

    /// Reads/writes the UP preset's enabled state; writing also mirrors it onto DOWN.
    var sharedIsEnabled: Bool {
        get { presets.first(where: { $0.button == .up })?.isEnabled ?? true }
        set {
            for index in presets.indices {
                presets[index].isEnabled = newValue
            }
        }
    }

    /// Called when switching into shared mode so the two presets don't silently disagree.
    private func syncDownToUp() {
        guard let upIndex = presets.firstIndex(where: { $0.button == .up }),
              let downIndex = presets.firstIndex(where: { $0.button == .down }) else { return }
        presets[downIndex].shortcutName = presets[upIndex].shortcutName
        presets[downIndex].isEnabled = presets[upIndex].isEnabled
    }

    private func persistPresets() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        UserDefaults.standard.set(data, forKey: presetsKey)
    }

    private func persistMode() {
        UserDefaults.standard.set(isSharedShortcut, forKey: modeKey)
    }
}
