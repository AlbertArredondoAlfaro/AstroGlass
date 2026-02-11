import GoogleMobileAds
import SwiftUI

struct AdBannerView: UIViewRepresentable {
    let adUnitId: String

    func makeUIView(context: Context) -> BannerView {
        let width = UIScreen.main.bounds.width - 24
        let banner = BannerView(adSize: largeAnchoredAdaptiveBanner(width: width))
        banner.adUnitID = adUnitId
        banner.rootViewController = UIApplication.shared.topMostViewController() ?? UIViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
