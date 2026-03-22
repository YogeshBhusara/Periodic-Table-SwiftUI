import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var uiState: UIStateManager

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Interactions")) {
                    Toggle(isOn: $uiState.isParticleEffectsEnabled) {
                        Label("Particle Effects", systemImage: "sparkles")
                    }

                    Toggle(isOn: $uiState.isSoundEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2")
                    }
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(buildNumber)
                    }
                }

                Section(header: Text("Reset")) {
                    Button(role: .destructive) {
                        resetPreferences()
                    } label: {
                        Label("Reset Filters", systemImage: "arrow.uturn.backward")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private func resetPreferences() {
        HapticManager.shared.playSelectionChange()
        uiState.resetFilters()
    }
}

#if DEBUG
#Preview {
    SettingsView()
        .environmentObject(UIStateManager())
}
#endif
