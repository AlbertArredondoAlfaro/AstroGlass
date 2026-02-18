import GoogleMobileAds
import SwiftUI

struct AdBannerView: UIViewRepresentable {
    let adUnitId: String

    final class Coordinator {
        var lastWidth: CGFloat = 0
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: largeAnchoredAdaptiveBanner(width: 320))
        banner.adUnitID = adUnitId
        banner.rootViewController = UIApplication.shared.topMostViewController() ?? UIViewController()
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        let windowWidth = uiView.window?.windowScene?.screen.bounds.width ?? 0
        let availableWidth = max(uiView.bounds.width, windowWidth) - 24
        let width = max(320, availableWidth)
        guard abs(width - context.coordinator.lastWidth) > 1 else { return }

        context.coordinator.lastWidth = width
        uiView.adSize = largeAnchoredAdaptiveBanner(width: width)
        uiView.load(Request())
    }
}
