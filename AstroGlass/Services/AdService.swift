import AppTrackingTransparency
import Foundation
import GoogleMobileAds
import Observation
import UIKit

@MainActor
@Observable
final class AdService: NSObject {
    private let defaults = UserDefaults.standard

    // Test IDs. Replace with production IDs before release.
    let bannerAdUnitId = "ca-app-pub-3940256099942544/2435281174"
    let interstitialAdUnitId = "ca-app-pub-3940256099942544/4411468910"

    var isRemoveAdsPurchased: Bool
    private var interstitial: InterstitialAd?

    var shouldShowBanner: Bool { !isRemoveAdsPurchased }

    private var lastInterstitialDate: Date? {
        let ts = defaults.double(forKey: DefaultsKeys.lastInterstitialTimestamp)
        guard ts > 0 else { return nil }
        return Date(timeIntervalSinceReferenceDate: ts)
    }

    var canShowInterstitial: Bool {
        guard shouldShowBanner else { return false }
        guard let last = lastInterstitialDate else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    override init() {
        isRemoveAdsPurchased = defaults.bool(forKey: DefaultsKeys.removeAdsPurchased)
        super.init()
    }

    func bootstrap() async {
        guard shouldShowBanner else { return }
        await requestTrackingIfNeeded()
        await MobileAds.shared.start()
        await loadInterstitial()
    }

    func requestTrackingIfNeeded() async {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    func loadInterstitial() async {
        do {
            let ad = try await InterstitialAd.load(with: interstitialAdUnitId, request: Request())
            ad.fullScreenContentDelegate = self
            interstitial = ad
        } catch {
            interstitial = nil
        }
    }

    func showInterstitialIfAllowed() {
        // Temporarily disabled while weekly forecast should always be accessible.
        // Re-enable in monetization pass.
        return
    }
}

extension AdService: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { await loadInterstitial() }
    }
}
