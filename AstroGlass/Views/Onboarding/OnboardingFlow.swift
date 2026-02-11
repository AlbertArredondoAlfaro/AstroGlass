import Foundation

enum OnboardingStep: Int, CaseIterable {
    case name
    case birthDate
    case birthTime
    case birthCity

    var subtitleKey: String {
        switch self {
        case .name:
            return "onboarding.subtitle.name"
        case .birthDate:
            return "onboarding.subtitle.birthdate"
        case .birthTime:
            return "onboarding.subtitle.birthtime"
        case .birthCity:
            return "onboarding.subtitle.city"
        }
    }

    var nextButtonKey: String {
        self == .birthCity ? "action.finish" : "action.next"
    }
}

enum OnboardingFlow {
    static let titleKey = "onboarding.title.name"

    static func canContinue(
        step: OnboardingStep,
        trimmedName: String,
        cityName: String,
        isResolvingCity: Bool
    ) -> Bool {
        switch step {
        case .name:
            return !trimmedName.isEmpty
        case .birthDate, .birthTime:
            return true
        case .birthCity:
            return !cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isResolvingCity
        }
    }

    static func nextStep(after step: OnboardingStep) -> OnboardingStep? {
        switch step {
        case .name:
            return .birthDate
        case .birthDate:
            return .birthTime
        case .birthTime:
            return .birthCity
        case .birthCity:
            return nil
        }
    }

    static func previousStep(before step: OnboardingStep) -> OnboardingStep? {
        switch step {
        case .name:
            return nil
        case .birthDate:
            return .name
        case .birthTime:
            return .birthDate
        case .birthCity:
            return .birthTime
        }
    }
}
