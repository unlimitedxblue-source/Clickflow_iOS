import CoreMotion
import Observation

/// Monitors device attitude via CoreMotion to detect pocket-facing-down orientation.
@MainActor
@Observable
final class MotionDetector {
    private(set) var isGuardActive: Bool = false
    private(set) var currentPitch: Double = 0
    private(set) var currentRoll: Double = 0

    /// Consecutive-sample thresholds guard against a single noisy reading flipping state.
    private let pocketPitchThreshold: Double = -1.0
    private let recoveryPitchThreshold: Double = -0.4
    private let updateInterval: TimeInterval = 1.0 / 30.0
    private let requiredConsecutiveSamples = 5

    private let motionManager = CMMotionManager()
    private var pocketCandidateCount = 0
    private var recoveryCandidateCount = 0

    var onGuardStateChanged: ((Bool) -> Void)?

    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else { return }
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.process(pitch: motion.attitude.pitch, roll: motion.attitude.roll)
        }
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        pocketCandidateCount = 0
        recoveryCandidateCount = 0
    }

    private func process(pitch: Double, roll: Double) {
        currentPitch = pitch
        currentRoll = roll

        if !isGuardActive {
            if pitch < pocketPitchThreshold {
                pocketCandidateCount += 1
                if pocketCandidateCount >= requiredConsecutiveSamples {
                    setGuardActive(true)
                }
            } else {
                pocketCandidateCount = 0
            }
        } else {
            if pitch > recoveryPitchThreshold {
                recoveryCandidateCount += 1
                if recoveryCandidateCount >= requiredConsecutiveSamples {
                    setGuardActive(false)
                }
            } else {
                recoveryCandidateCount = 0
            }
        }
    }

    func forceRecover() {
        setGuardActive(false)
    }

    private func setGuardActive(_ active: Bool) {
        guard isGuardActive != active else { return }
        isGuardActive = active
        pocketCandidateCount = 0
        recoveryCandidateCount = 0
        onGuardStateChanged?(active)
    }
}
