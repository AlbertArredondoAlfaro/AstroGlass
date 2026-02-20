import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let cityLookupService = CityLookupService()

    @State private var step: OnboardingStep = .name
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var hasExactTime = false
    @State private var birthTime = Date()
    @State private var cityName = ""
    @State private var cityErrorKey: String?
    @State private var isResolvingCity = false
    @State private var resolvedCity: City?
    @State private var didPrefillFromProfile = false

    private var cardMaxWidth: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.cardMaxWidthRegular : AppTheme.Metrics.cardMaxWidthCompact
    }

    private var sidePadding: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.sidePaddingRegular : AppTheme.Metrics.sidePaddingCompact
    }

    private var timePickerWidth: CGFloat {
        horizontalSizeClass == .regular ? 280 : 220
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canContinueCurrentStep: Bool {
        OnboardingFlow.canContinue(
            step: step,
            trimmedName: trimmedName,
            cityName: cityName,
            isResolvingCity: isResolvingCity
        )
    }

    private var titleKey: String {
        OnboardingFlow.titleKey
    }

    private var subtitleKey: String {
        step.subtitleKey
    }

    private var nextButtonKey: String {
        return step.nextButtonKey
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 20) {
                Spacer(minLength: 0)

                Text(String(localized: String.LocalizationValue(titleKey)))
                    .font(AppTheme.Typography.displaySerif(40))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: cardMaxWidth, alignment: .center)
                    .padding(.horizontal, sidePadding)

                VStack(alignment: .leading, spacing: 18) {
                    Text(String(localized: String.LocalizationValue(subtitleKey)))
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Group {
                        switch step {
                        case .name:
                            TextField(String(localized: "onboarding.placeholder.name"), text: $name)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.continue)
                                .onSubmit(continueToNextStep)
                                .padding(.horizontal, 14)
                                .frame(height: AppTheme.Metrics.textFieldHeight)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.fieldCornerRadius, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Metrics.fieldCornerRadius, style: .continuous)
                                        .stroke(.white.opacity(0.18), lineWidth: 1)
                                )
                        case .birthDate:
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                                .tint(AppTheme.Colors.accentLilac)
                                .scaleEffect(0.92)
                                .frame(maxWidth: .infinity)
                        case .birthTime:
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $hasExactTime) {
                                    Text(String(localized: "onboarding.toggle.time"))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                    .tint(AppTheme.Colors.accentLilac)

                                if hasExactTime {
                                    HStack {
                                        Spacer(minLength: 0)
                                        DatePicker("", selection: $birthTime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.wheel)
                                            .labelsHidden()
                                            .frame(width: timePickerWidth, height: 180)
                                            .clipped()
                                        Spacer(minLength: 0)
                                    }
                                } else {
                                    Text(String(localized: "onboarding.note.approx"))
                                        .font(AppTheme.Typography.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        case .birthCity:
                            VStack(alignment: .leading, spacing: 12) {
                                TextField(String(localized: "onboarding.placeholder.city"), text: $cityName)
                                    .textInputAutocapitalization(.words)
                                    .submitLabel(.done)
                                    .onSubmit(continueToNextStep)
                                    .onChange(of: cityName) { _, _ in
                                        resolvedCity = nil
                                        cityErrorKey = nil
                                    }
                                    .padding(.horizontal, 14)
                                    .frame(height: AppTheme.Metrics.textFieldHeight)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.fieldCornerRadius, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Metrics.fieldCornerRadius, style: .continuous)
                                            .stroke(.white.opacity(0.18), lineWidth: 1)
                                    )

                                Text(String(localized: "onboarding.city.helper"))
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                if isResolvingCity {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text(String(localized: "onboarding.city.loading"))
                                    }
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundStyle(.secondary)
                                }

                                if let cityErrorKey {
                                    Text(String(localized: String.LocalizationValue(cityErrorKey)))
                                        .font(AppTheme.Typography.footnote)
                                        .foregroundStyle(.red.opacity(0.9))
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                if let resolvedCity {
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AppTheme.Colors.accentLilac)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(String(localized: "onboarding.city.confirmed"))
                                                .font(AppTheme.Typography.headline)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Text("\(resolvedCity.name), \(resolvedCity.country)")
                                                .font(AppTheme.Typography.body)
                                                .foregroundStyle(.white.opacity(0.95))
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .layoutPriority(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(AppTheme.Colors.accentLilac.opacity(0.6), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .transition(.opacity)
                }
                .id(step)
                .padding(AppTheme.Metrics.cardPadding)
                .frame(maxWidth: cardMaxWidth)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Metrics.cardCornerRadius, style: .continuous)
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.34), radius: 22, x: 0, y: 10)
                .padding(.horizontal, sidePadding)
                .animation(.spring(response: 0.55, dampingFraction: 0.62), value: step)

                HStack(spacing: 12) {
                    if step != .name {
                        Button(String(localized: "action.back"), action: goBackStep)
                            .frame(height: AppTheme.Metrics.primaryButtonHeight)
                            .buttonStyle(AstroGlassSecondaryButtonStyle(fullWidth: true))
                            .frame(maxWidth: .infinity)
                    }

                    Button(String(localized: String.LocalizationValue(nextButtonKey)), action: continueToNextStep)
                        .frame(height: AppTheme.Metrics.primaryButtonHeight)
                        .buttonStyle(AstroGlassPrimaryButtonStyle(fullWidth: true))
                        .disabled(!canContinueCurrentStep || isResolvingCity)
                        .opacity((canContinueCurrentStep && !isResolvingCity) ? 1 : 0.55)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: cardMaxWidth)
                .padding(.horizontal, sidePadding)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear(perform: prefillIfNeeded)
    }

    private func continueToNextStep() {
        guard canContinueCurrentStep else { return }
        if let next = OnboardingFlow.nextStep(after: step) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) {
                step = next
            }
        } else {
            Task {
                if let resolvedCity {
                    finishOnboarding(with: resolvedCity)
                } else {
                    await resolveCityForConfirmation()
                }
            }
        }
    }

    private func goBackStep() {
        if let previous = OnboardingFlow.previousStep(before: step) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) {
                step = previous
            }
        }
    }

    private func resolveCityForConfirmation() async {
        guard !isResolvingCity else { return }

        cityErrorKey = nil
        resolvedCity = nil
        isResolvingCity = true
        defer { isResolvingCity = false }

        do {
            let city = try await cityLookupService.resolveCity(named: cityName)
            resolvedCity = city
        } catch let error as CityLookupService.LookupError {
            cityErrorKey = error.localizedKey
        } catch {
            cityErrorKey = CityLookupService.LookupError.unknown.localizedKey
        }
    }

    private func finishOnboarding(with city: City) {
        let birthTimeValue: BirthTime? = hasExactTime ? birthTime.toBirthTime : nil
        model.updateProfile(name: trimmedName, birthDate: birthDate, birthTime: birthTimeValue, city: city)
    }

    private func prefillIfNeeded() {
        guard !didPrefillFromProfile else { return }
        didPrefillFromProfile = true
        guard let profile = model.profile else { return }

        name = profile.name
        birthDate = profile.birthDate
        cityName = profile.cityName
        hasExactTime = profile.birthTime != nil
        if let bt = profile.birthTime,
           let date = Calendar.current.date(from: DateComponents(hour: bt.hour, minute: bt.minute)) {
            birthTime = date
        }
    }
}
