import Foundation

/// A single volume-button press mapped to a Shortcuts app automation.
struct CommandPreset: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var button: VolumeButtonInput
    var isEnabled: Bool = true
    /// The Shortcuts app automation name to run when this preset is triggered.
    var shortcutName: String = ""
}

enum VolumeButtonInput: String, Codable {
    case up
    case down

    /// Localized label used everywhere this preset's button is displayed, e.g. "音量ボタン 上".
    var localizedLabelKey: String {
        switch self {
        case .up: return "preset.button.up"
        case .down: return "preset.button.down"
        }
    }
}
