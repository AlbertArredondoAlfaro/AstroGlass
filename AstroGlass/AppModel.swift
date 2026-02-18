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
    var isLoadingAIModel = false

    let horoscopeService = HoroscopeService()
    let purchaseService = PurchaseService()
    let adService = AdService()
    let notificationScheduler = NotificationScheduler()
    private var horoscopeTask: Task<Void, Never>?
    private var lastForecastLanguageCode: String?

    init() {
        hasCompletedOnboarding = defaults.bool(forKey: DefaultsKeys.hasCompletedOnboarding)
        notificationsEnabled = defaults.bool(forKey: DefaultsKeys.notificationsEnabled)
        restoreProfile()
    }

    func bootstrap() async {
        refreshHoroscope()

        let hasRequestedNotificationPermission = defaults.bool(forKey: DefaultsKeys.notificationsPermissionRequested)
        if !hasRequestedNotificationPermission,
           await notificationScheduler.authorizationStatus() == .notDetermined {
            let granted = await notificationScheduler.requestAuthorizationIfNeeded()
            defaults.set(true, forKey: DefaultsKeys.notificationsPermissionRequested)
            notificationsEnabled = granted
        }

        await purchaseService.bootstrap()
        adService.isRemoveAdsPurchased = purchaseService.isPurchased
        await adService.bootstrap()

        if notificationsEnabled {
            await notificationScheduler.scheduleWeekly()
        } else {
            notificationScheduler.cancelWeekly()
        }
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

        persistProfile()
        hasCompletedOnboarding = true
        refreshHoroscope()
    }

    func refreshHoroscope(for date: Date = Date()) {
        guard let profile else {
            weeklyHoroscope = nil
            isLoadingHoroscope = false
            isLoadingAIModel = false
            return
        }

        horoscopeTask?.cancel()
        isLoadingHoroscope = true
        isLoadingAIModel = true
        let week = Calendar.current.component(.weekOfYear, from: date)
        let yearForWeekOfYear = Calendar.current.component(.yearForWeekOfYear, from: date)
        let service = horoscopeService
        let languageCode = CoreMLForecastService.shared.currentLanguageCode()

        horoscopeTask = Task { [weak self, profile, week, yearForWeekOfYear, service, languageCode] in
            let generated = await Task.detached(priority: .userInitiated) {
                await service.weeklyHoroscope(
                    for: profile.sunSign,
                    risingSign: profile.risingSign,
                    weekOfYear: week,
                    yearForWeekOfYear: yearForWeekOfYear,
                    profileID: profile.id
                )
            }.value

            guard let self, !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.58, dampingFraction: 0.62)) {
                self.weeklyHoroscope = generated
                self.isLoadingHoroscope = false
                self.isLoadingAIModel = false
                self.lastForecastLanguageCode = languageCode
            }
        }
    }

    func refreshHoroscopeIfLanguageChanged() {
        let currentLanguage = CoreMLForecastService.shared.currentLanguageCode()
        guard currentLanguage != lastForecastLanguageCode else { return }
        refreshHoroscope()
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
        guard let data = defaults.data(forKey: DefaultsKeys.profileData) else {
            profile = nil
            hasCompletedOnboarding = false
            return
        }

        guard let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            profile = nil
            hasCompletedOnboarding = false
            return
        }

        profile = decoded
        hasCompletedOnboarding = true
    }

}
