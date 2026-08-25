import SwiftUI

struct StatusIndicator: View {
    let isActive: Bool
    let activeLabelKey: LocalizedStringKey
    let idleLabelKey: LocalizedStringKey

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isActive ? Color.clickflowVividEmerald : Color.gray)
                .frame(width: 10, height: 10)
                .shadow(color: isActive ? Color.clickflowVividEmerald.opacity(0.8) : .clear, radius: 6)

            Text(isActive ? activeLabelKey : idleLabelKey)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

#Preview {
    ZStack {
        Color.clickflowBackground.ignoresSafeArea()
        StatusIndicator(isActive: true, activeLabelKey: "status.guarding", idleLabelKey: "status.idle")
    }
}
