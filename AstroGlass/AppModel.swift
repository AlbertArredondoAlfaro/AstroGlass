import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class AppModel {
    private let defaults = UserDefaults.standard

    var profile: UserProfile? {
        didSet { persistProfile() }
    }

    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: DefaultsKeys.hasCompletedOnboarding) }
    }

    var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: DefaultsKeys.notificationsEnabled) }
    }

    var weeklyHoroscope: Horoscope?
    var isLoadingHoroscope = false

    let horoscopeService = HoroscopeService()
    let purchaseService = PurchaseService()
    let adService = AdService()
    let notificationScheduler = NotificationScheduler()

    init() {
        hasCompletedOnboarding = defaults.bool(forKey: DefaultsKeys.hasCompletedOnboarding)
        notificationsEnabled = defaults.bool(forKey: DefaultsKeys.notificationsEnabled)
        profile = nil
        restoreProfile()
    }

    func bootstrap() async {
        await purchaseService.bootstrap()
        adService.isRemoveAdsPurchased = purchaseService.isPurchased
        await adService.bootstrap()

        if notificationsEnabled {
            await notificationScheduler.scheduleWeekly()
        }

        refreshHoroscope()
    }

    func updateProfile(name: String, birthDate: Date, birthTime: BirthTime?, city: City) {
        let sunSign = ZodiacCalculator.sunSign(for: birthDate)
        let risingSign = AscendantCalculator.risingSign(
            birthDate: birthDate,
            birthTime: birthTime,
            latitude: city.latitude,
            longitude: city.longitude,
            timeZoneId: city.timeZoneId
        )

        profile = UserProfile(
            id: UUID(),
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            cityName: "\(city.name), \(city.country)",
            latitude: city.latitude,
            longitude: city.longitude,
            timeZoneId: city.timeZoneId,
            sunSign: sunSign,
            risingSign: risingSign
        )

        hasCompletedOnboarding = true
        refreshHoroscope()
    }

    func refreshHoroscope(for date: Date = Date()) {
        guard let profile else { return }

        isLoadingHoroscope = true
        let week = Calendar.current.component(.weekOfYear, from: date)
        let generated = horoscopeService.weeklyHoroscope(for: profile.sunSign, weekOfYear: week)

        withAnimation(.spring(response: 0.58, dampingFraction: 0.62)) {
            weeklyHoroscope = generated
            isLoadingHoroscope = false
        }
    }

    func toggleNotifications() async {
        if notificationsEnabled {
            await notificationScheduler.scheduleWeekly()
        } else {
            notificationScheduler.cancelWeekly()
        }
    }

    func syncPurchaseState() {
        adService.isRemoveAdsPurchased = purchaseService.isPurchased
    }

    private func persistProfile() {
        guard let profile else {
            defaults.removeObject(forKey: DefaultsKeys.profileData)
            return
        }

        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: DefaultsKeys.profileData)
        }
    }

    private func restoreProfile() {
        guard let data = defaults.data(forKey: DefaultsKeys.profileData),
              let decoded = try? JSONDecoder().decode(UserProfile.self, from: data)
        else { return }

        profile = decoded
    }
}
