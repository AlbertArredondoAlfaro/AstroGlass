import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            if model.hasCompletedOnboarding {
                MainTabView()
                    .safeAreaInset(edge: .bottom) {
                        if model.adService.shouldShowBanner {
                            AdBannerContainerView(adUnitId: model.adService.bannerAdUnitId)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                OnboardingView()
                    .transition(.opacity)
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
    }
}
