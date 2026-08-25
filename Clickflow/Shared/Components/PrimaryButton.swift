import SwiftUI

struct PrimaryButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(titleKey, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.black)
                .background(LinearGradient.clickflowAccent)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.clickflowBackground.ignoresSafeArea()
        PrimaryButton(titleKey: "button.startGuard", systemImage: "shield.fill") {}
            .padding()
    }
}
