import SwiftUI

struct ActiveGuardOverlayView: View {
    let onManualRecover: () -> Void

    @State private var longPressProgress: CGFloat = 0
    @State private var isPressing = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 34))
                    .foregroundStyle(.white.opacity(0.06))

                if isPressing {
                    ProgressView(value: longPressProgress)
                        .progressViewStyle(.linear)
                        .tint(.white.opacity(0.2))
                        .frame(width: 120)
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(recoveryGesture)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .accessibilityHidden(true)
    }

    private var recoveryGesture: some Gesture {
        LongPressGesture(minimumDuration: 3.0)
            .onChanged { _ in
                isPressing = true
                withAnimation(.linear(duration: 3.0)) {
                    longPressProgress = 1.0
                }
            }
            .onEnded { _ in
                onManualRecover()
                resetPressState()
            }
            .simultaneously(with: DragGesture(minimumDistance: 0).onEnded { _ in
                if longPressProgress < 1.0 {
                    resetPressState()
                }
            })
    }

    private func resetPressState() {
        isPressing = false
        withAnimation(.easeOut(duration: 0.2)) {
            longPressProgress = 0
        }
    }
}

#Preview {
    ActiveGuardOverlayView(onManualRecover: {})
}
