import UIKit

@MainActor
final class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()

    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let successGenerator = UINotificationFeedbackGenerator()
    private let tapGenerator = UIImpactFeedbackGenerator(style: .light)

    private init() {
        heavyGenerator.prepare()
        successGenerator.prepare()
        tapGenerator.prepare()
    }

    func fireGuardTransition() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    func fireCommandSuccess() {
        successGenerator.notificationOccurred(.success)
        successGenerator.prepare()
    }

    /// Light acknowledgement for a single volume button press, distinct from a full command match.
    func fireButtonAck() {
        tapGenerator.impactOccurred()
        tapGenerator.prepare()
    }
}
