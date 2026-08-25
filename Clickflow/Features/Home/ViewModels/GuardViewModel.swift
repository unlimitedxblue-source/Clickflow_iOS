import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class GuardViewModel {
    private(set) var isGuardActive: Bool = false
    var commandFeedbackToken: Int = 0

    private let motionDetector = MotionDetector()
    private let volumeListener = VolumeCommandListener()

    init() {
        motionDetector.onGuardStateChanged = { [weak self] active in
            self?.handleGuardStateChanged(active)
        }
        volumeListener.onCommandMatched = { [weak self] preset in
            self?.handleCommandMatched(preset)
        }
        volumeListener.onButtonPressed = { _ in
            HapticFeedbackManager.shared.fireButtonAck()
        }
    }

    func startMonitoring() {
        motionDetector.startMonitoring()
        volumeListener.presets = PresetStore.shared.presets
        volumeListener.startListening()
    }

    func stopMonitoring() {
        motionDetector.stopMonitoring()
        volumeListener.stopListening()
    }

    func manualRecover() {
        motionDetector.forceRecover()
    }

    /// Re-asserts idle-timer suppression when Clickflow returns to the foreground
    /// (e.g. after briefly switching to the Shortcuts app), in case iOS reset it
    /// during the hand-off. A no-op when the guard isn't currently active.
    func reassertGuardStateIfNeeded() {
        guard isGuardActive else { return }
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func handleGuardStateChanged(_ active: Bool) {
        isGuardActive = active
        UIApplication.shared.isIdleTimerDisabled = active
        HapticFeedbackManager.shared.fireGuardTransition()
    }

    private func handleCommandMatched(_ preset: CommandPreset) {
        commandFeedbackToken += 1
        HapticFeedbackManager.shared.fireCommandSuccess()
        ShortcutRunner.run(name: preset.shortcutName)
    }
}

extension CommandPreset {
    static let defaultPresets: [CommandPreset] = [
        CommandPreset(button: .up, shortcutName: "Play/Pause"),
        CommandPreset(button: .down, shortcutName: "")
    ]
}
