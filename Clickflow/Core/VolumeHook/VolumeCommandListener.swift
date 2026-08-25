import AVFAudio
import Observation
import MediaPlayer
import UIKit

/// Observes system output volume changes to detect single volume-button presses.
@MainActor
@Observable
final class VolumeCommandListener: NSObject {
    private(set) var lastMatchedInput: VolumeButtonInput?
    private(set) var commandTriggerToken: Int = 0

    var presets: [CommandPreset] = []
    var onCommandMatched: ((CommandPreset) -> Void)?
    /// Fires for every raw volume button press, before any preset lookup.
    var onButtonPressed: ((VolumeButtonInput) -> Void)?

    private let session = AVAudioSession.sharedInstance()

    /// How close a reading must be to the reset target to be treated as our
    /// own reset rather than a real press. A step is ~1/16 (0.0625), so this
    /// is comfortably tighter than any real press could land.
    private let resetEpsilon: Float = 0.02

    private var observation: NSKeyValueObservation?
    private var lastVolume: Float = 0.5
    /// Set right before we command the volume back down. Unlike a plain
    /// boolean flag, we also check the incoming value against `baselineVolume`
    /// so a real press that races ahead of our own pending reset (both are
    /// async) is still recognized as real instead of being swallowed as ours.
    private var awaitingReset = false
    /// The volume in effect when monitoring FIRST started. Every restore always
    /// targets THIS value — not whatever `lastVolume` happens to be — so a
    /// burst of rapid presses can't drift the volume one step at a time if
    /// their pending resets race each other; everything always converges back
    /// to the true original.
    ///
    /// Deliberately NOT re-captured every time startListening() runs: a
    /// Shortcut trigger backgrounds Clickflow, and any volume change that
    /// happens while backgrounded goes unobserved. If we re-snapshotted the
    /// baseline on every foreground re-arm, that drifted value would get
    /// "locked in" as the new target — explaining a volume that crept up (or
    /// down) with every Shortcut round-trip. `hasBaseline` makes this a
    /// one-time capture per monitoring session instead.
    private var baselineVolume: Float = 0.5
    private var hasBaseline = false
    /// Persists the baseline across a full process relaunch — a Shortcut
    /// hand-off can lead iOS to terminate Clickflow outright rather than just
    /// suspending it, which would otherwise lose the true original volume.
    private let baselineDefaultsKey = "com.unlimitedxblue.clickflow.baselineVolume"

    /// A hidden system volume view is required to route volume changes silently, without the HUD's own slider.
    /// Its internal UISlider is only instantiated once the view is actually part of a window's hierarchy.
    private let hiddenVolumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))

    func startListening() {
        observation?.invalidate()
        observation = nil

        do {
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            return
        }

        installHiddenVolumeView()

        lastVolume = session.outputVolume
        if !hasBaseline {
            // NSNumber → Float bridging via `as?` is unreliable (it frequently
            // returns nil even when a value is present), so the baseline is
            // stored/read as Double, which bridges from UserDefaults correctly.
            if UserDefaults.standard.object(forKey: baselineDefaultsKey) != nil {
                baselineVolume = Float(UserDefaults.standard.double(forKey: baselineDefaultsKey))
            } else {
                baselineVolume = lastVolume
                UserDefaults.standard.set(Double(baselineVolume), forKey: baselineDefaultsKey)
            }
            hasBaseline = true
        }
        if abs(lastVolume - baselineVolume) >= resetEpsilon {
            // Volume drifted while we were backgrounded (e.g. presses that
            // happened during a Shortcut round-trip went unobserved) — correct
            // it now instead of waiting for the next button press.
            restoreVolume(to: baselineVolume)
        }

        observation = session.observe(\.outputVolume, options: [.new, .old]) { [weak self] _, change in
            guard let self, let newValue = change.newValue else { return }
            Task { @MainActor in
                self.handleVolumeChange(newValue)
            }
        }
    }

    func stopListening() {
        observation?.invalidate()
        observation = nil
        hasBaseline = false
        UserDefaults.standard.removeObject(forKey: baselineDefaultsKey)
    }

    private func handleVolumeChange(_ newVolume: Float) {
        defer { lastVolume = newVolume }

        if awaitingReset, abs(newVolume - baselineVolume) < resetEpsilon {
            awaitingReset = false
            return
        }

        let input: VolumeButtonInput = newVolume > lastVolume ? .up : .down
        onButtonPressed?(input)

        // Restore the volume BEFORE firing the matched command: running a
        // Shortcut backgrounds this app via UIApplication.open, and once that
        // hand-off has started, a programmatic volume change no longer reliably
        // reaches the system — leaving the volume permanently drifted.
        restoreVolume(to: baselineVolume)

        if let preset = presets.first(where: { $0.isEnabled && $0.button == input }) {
            lastMatchedInput = input
            commandTriggerToken += 1
            onCommandMatched?(preset)
        }
    }

    /// Adding the volume view to the key window (off-screen) is required for its
    /// UISlider to exist at all; without this, restoreVolume silently no-ops
    /// forever and repeated same-direction presses eventually hit 0.0/1.0 and stop
    /// producing further KVO changes.
    private func installHiddenVolumeView() {
        guard hiddenVolumeView.superview == nil else { return }
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        window.addSubview(hiddenVolumeView)
    }

    private func restoreVolume(to target: Float) {
        guard let slider = hiddenVolumeView.subviews.compactMap({ $0 as? UISlider }).first else { return }
        awaitingReset = true
        slider.setValue(target, animated: false)
        slider.sendActions(for: .touchUpInside)
    }
}
