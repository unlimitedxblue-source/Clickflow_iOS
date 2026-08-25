import SwiftUI

struct SettingsView: View {
    @State private var store = PresetStore.shared

    var body: some View {
        ZStack {
            Color.clickflowBackground.ignoresSafeArea()

            List {
                Section {
                    Picker("settings.presetMode.label", selection: $store.isSharedShortcut) {
                        Text("settings.presetMode.shared").tag(true)
                        Text("settings.presetMode.separate").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    if store.isSharedShortcut {
                        sharedRow
                            .listRowBackground(Color.clickflowGlass)
                    } else {
                        ForEach($store.presets) { $preset in
                            presetRow(preset: $preset)
                        }
                        .listRowBackground(Color.clickflowGlass)
                    }
                } header: {
                    Text("settings.presets.header")
                        .foregroundStyle(.white.opacity(0.6))
                } footer: {
                    Text("settings.presets.footer")
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("settings.title")
        .preferredColorScheme(.dark)
    }

    private var sharedRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(Color.clickflowNeonCyan)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("settings.sharedShortcut.title")
                        .foregroundStyle(.white)
                    Text("▲ ▼")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { store.sharedIsEnabled },
                    set: { store.sharedIsEnabled = $0 }
                ))
                .labelsHidden()
                .tint(Color.clickflowVividEmerald)
            }

            TextField("settings.shortcutName.placeholder", text: Binding(
                get: { store.sharedShortcutName },
                set: { store.sharedShortcutName = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled()
            .padding(.leading, 36)
        }
        .padding(.vertical, 4)
    }

    private func presetRow(preset: Binding<CommandPreset>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(Color.clickflowNeonCyan)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("settings.sharedShortcut.title")
                        .foregroundStyle(.white)
                    Text(preset.wrappedValue.button == .up ? "▲" : "▼")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Toggle("", isOn: preset.isEnabled)
                    .labelsHidden()
                    .tint(Color.clickflowVividEmerald)
            }

            TextField("settings.shortcutName.placeholder", text: preset.shortcutName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .padding(.leading, 36)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
