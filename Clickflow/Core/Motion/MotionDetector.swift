import CoreMotion
import Observation

/// Monitors device attitude via CoreMotion to detect pocket-facing-down orientation.
@MainActor
@Observable
final class MotionDetector {
    private(set) var isGuardActive: Bool = false
    private(set) var currentPitch: Double = 0
    private(set) var currentRoll: Double = 0

    /// Pocket entry threshold: device head facing downwards with screen oriented inwards/downwards
    private let pocketPitchThreshold: Double = -1.0
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
            self.process(motion: motion)
        }
    }

    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        pocketCandidateCount = 0
        recoveryCandidateCount = 0
    }

    private func process(motion: CMDeviceMotion) {
        let pitch = motion.attitude.pitch
        let roll = motion.attitude.roll
        let gravity = motion.gravity

        currentPitch = pitch
        currentRoll = roll

        if !isGuardActive {
            // Guard Activation: Head down into pocket (pitch < -1.0 or gravity.y > 0.7)
            let isPocketDown = pitch < pocketPitchThreshold || (gravity.y > 0.7 && gravity.z > -0.2)
            if isPocketDown {
                pocketCandidateCount += 1
                if pocketCandidateCount >= requiredConsecutiveSamples {
                    setGuardActive(true)
                }
            } else {
                pocketCandidateCount = 0
            }
        } else {
            // Guard Deactivation: Strictly when the device is fully face-up and upright for operation
            // Prevent accidental recovery when the device is merely turned sideways (landscape/horizontal tilt)
            let isNotSideways = abs(roll) < 0.45 && abs(gravity.x) < 0.4
            let isFaceUpOrUpright = (gravity.z < -0.35 && pitch > -0.3) || (pitch > -0.25 && pitch < 1.1 && gravity.z < 0.2)
            let isFullyFaceUp = isNotSideways && isFaceUpOrUpright

            if isFullyFaceUp {
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
