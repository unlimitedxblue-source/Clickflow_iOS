import SwiftUI

struct ActiveGuardOverlayView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 38))
                    .foregroundStyle(.white.opacity(0.05))
            }
        }
        .contentShape(Rectangle())
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .accessibilityHidden(true)
    }
}

#Preview {
    ActiveGuardOverlayView()
}
