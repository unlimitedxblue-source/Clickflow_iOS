import SwiftUI

struct HomeView: View {
    /// Switching to the Shortcuts app can lead iOS to fully terminate Clickflow
    /// in the background rather than just suspending it; when that happens,
    /// "clickflow://" relaunches the app from scratch and all in-memory state
    /// (isMonitoring, isGuardActive) is lost. Persisting this flag lets launch
    /// auto-resume monitoring, so if the phone is still in a pocket, motion
    /// detection re-arms the guard screen within a fraction of a second instead
    /// of silently staying in the idle "待機中" state.
    private static let isMonitoringKey = "com.unlimitedxblue.clickflow.isMonitoring"

    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = GuardViewModel()
    @State private var isMonitoring = false
    @State private var showingHelpGuide = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clickflowBackground.ignoresSafeArea()

                VStack(spacing: 24) {
                    StatusIndicator(
                        isActive: isMonitoring,
                        activeLabelKey: "status.monitoring",
                        idleLabelKey: "status.idle"
                    )
                    .padding(.top, 12)

                    Spacer()

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("home.guardExplainer.title", systemImage: "shield.lefthalf.filled")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("home.guardExplainer.body")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.6))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()

                    PrimaryButton(
                        titleKey: isMonitoring ? "button.stopGuard" : "button.startGuard",
                        systemImage: isMonitoring ? "stop.fill" : "shield.fill"
                    ) {
                        toggleMonitoring()
                    }
                }
                .padding(24)
            }
            .navigationTitle("home.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingHelpGuide = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingHelpGuide) {
                HelpGuideView()
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.isGuardActive },
            set: { newValue in
                if !newValue { viewModel.manualRecover() }
            }
        )) {
            ActiveGuardOverlayView(onManualRecover: {
                viewModel.manualRecover()
            })
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: viewModel.isGuardActive)
        .sensoryFeedback(.success, trigger: viewModel.commandFeedbackToken)
        .onAppear {
            if UserDefaults.standard.bool(forKey: Self.isMonitoringKey) {
                isMonitoring = true
                viewModel.startMonitoring()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            // Returning from a brief app switch (e.g. running a Shortcut) should
            // never leave the pitch-black guard screen dismissed or the screen
            // able to sleep, even if iOS reset something during the hand-off.
            viewModel.reassertGuardStateIfNeeded()
            guard isMonitoring else { return }
            // Running a Shortcut backgrounds the app, which can drop the audio
            // session and detach the hidden volume view; re-arm both so the
            // next volume-button press is still detected.
            viewModel.startMonitoring()
        }
    }

    private func toggleMonitoring() {
        isMonitoring.toggle()
        UserDefaults.standard.set(isMonitoring, forKey: Self.isMonitoringKey)
        if isMonitoring {
            viewModel.startMonitoring()
        } else {
            viewModel.stopMonitoring()
        }
    }
}

#Preview {
    HomeView()
}
