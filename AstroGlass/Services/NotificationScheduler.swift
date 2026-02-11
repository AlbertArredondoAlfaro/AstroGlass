import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler {
    private let center = UNUserNotificationCenter.current()
    private let weeklyIdentifier = "weeklyHoroscopeNotification"

    func scheduleWeekly() async {
        let settings = await center.notificationSettings()
        let granted: Bool

        switch settings.authorizationStatus {
        case .authorized, .provisional:
            granted = true
        case .notDetermined:
            granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            granted = false
        }

        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.weekly.title")
        content.body = String(localized: "notification.weekly.body")
        content.sound = .default

        var components = DateComponents()
        components.weekday = 2
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyIdentifier, content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [weeklyIdentifier])
        try? await center.add(request)
    }

    func cancelWeekly() {
        center.removePendingNotificationRequests(withIdentifiers: [weeklyIdentifier])
    }
}
