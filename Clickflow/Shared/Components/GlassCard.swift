import SwiftUI

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.clickflowGlass)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.clickflowGlassBorder, lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        Color.clickflowBackground.ignoresSafeArea()
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Guard Status")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Idle")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
    }
}
