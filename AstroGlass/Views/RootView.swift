import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            if model.hasCompletedOnboarding, model.profile != nil {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }

            if model.isLoadingAIModel {
                ZStack {
                    Color.black.opacity(0.26)
                        .ignoresSafeArea()

                    VStack(spacing: 14) {
                        ProgressView()
                            .controlSize(.large)
                            .tint(.white)

                        Text(String(localized: "ai.model.loading"))
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 10)
                    .padding(.horizontal, 28)
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .task {
            await model.bootstrap()
        }
        .onChange(of: model.purchaseService.isPurchased) { _, _ in
            model.syncPurchaseState()
        }
        .onChange(of: model.notificationsEnabled) { _, _ in
            Task { await model.toggleNotifications() }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)) { _ in
            model.refreshHoroscopeIfLanguageChanged()
        }
    }
}
