import XCTest
@testable import AstroGlass

final class OnboardingFlowTests: XCTestCase {
    func testCanContinueNameRequiresNonEmptyTrimmedName() {
        XCTAssertFalse(
            OnboardingFlow.canContinue(
                step: .name,
                trimmedName: "",
                cityName: "",
                isResolvingCity: false
            )
        )

        XCTAssertTrue(
            OnboardingFlow.canContinue(
                step: .name,
                trimmedName: "Albert",
                cityName: "",
                isResolvingCity: false
            )
        )
    }

    func testCanContinueBirthCityRequiresNonEmptyCityAndNoLoading() {
        XCTAssertFalse(
            OnboardingFlow.canContinue(
                step: .birthCity,
                trimmedName: "Albert",
                cityName: "  ",
                isResolvingCity: false
            )
        )

        XCTAssertFalse(
            OnboardingFlow.canContinue(
                step: .birthCity,
                trimmedName: "Albert",
                cityName: "Barcelona",
                isResolvingCity: true
            )
        )

        XCTAssertTrue(
            OnboardingFlow.canContinue(
                step: .birthCity,
                trimmedName: "Albert",
                cityName: "Barcelona",
                isResolvingCity: false
            )
        )
    }

    func testNextStepSequence() {
        XCTAssertEqual(OnboardingFlow.nextStep(after: .name), .birthDate)
        XCTAssertEqual(OnboardingFlow.nextStep(after: .birthDate), .birthTime)
        XCTAssertEqual(OnboardingFlow.nextStep(after: .birthTime), .birthCity)
        XCTAssertNil(OnboardingFlow.nextStep(after: .birthCity))
    }

    func testPreviousStepSequence() {
        XCTAssertNil(OnboardingFlow.previousStep(before: .name))
        XCTAssertEqual(OnboardingFlow.previousStep(before: .birthDate), .name)
        XCTAssertEqual(OnboardingFlow.previousStep(before: .birthTime), .birthDate)
        XCTAssertEqual(OnboardingFlow.previousStep(before: .birthCity), .birthTime)
    }

    func testStepLocalizationKeys() {
        XCTAssertEqual(OnboardingFlow.titleKey, "onboarding.title.name")
        XCTAssertEqual(OnboardingStep.name.subtitleKey, "onboarding.subtitle.name")
        XCTAssertEqual(OnboardingStep.birthDate.subtitleKey, "onboarding.subtitle.birthdate")
        XCTAssertEqual(OnboardingStep.birthTime.subtitleKey, "onboarding.subtitle.birthtime")
        XCTAssertEqual(OnboardingStep.birthCity.subtitleKey, "onboarding.subtitle.city")

        XCTAssertEqual(OnboardingStep.name.nextButtonKey, "action.next")
        XCTAssertEqual(OnboardingStep.birthDate.nextButtonKey, "action.next")
        XCTAssertEqual(OnboardingStep.birthTime.nextButtonKey, "action.next")
        XCTAssertEqual(OnboardingStep.birthCity.nextButtonKey, "action.finish")
    }
}
