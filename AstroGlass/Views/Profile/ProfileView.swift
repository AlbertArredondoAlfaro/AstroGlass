import SwiftUI

struct ProfileView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showResetConfirmation = false

    private var cardMaxWidth: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.cardMaxWidthRegular : AppTheme.Metrics.cardMaxWidthCompact
    }

    private var sidePadding: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.sidePaddingRegular : AppTheme.Metrics.sidePaddingCompact
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 0) {
                Text(String(localized: "profile.title"))
                    .font(AppTheme.Typography.displaySerif(25))
                    .foregroundStyle(.white.opacity(0.96))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.bottom, 12)

                GlassCard(style: .profile) {
                    if let profile = model.profile {
                        VStack(spacing: 10) {
                            Text(profile.name)
                                .font(AppTheme.Typography.title2)
                                .foregroundStyle(.white.opacity(0.97))

                            HStack(spacing: 8) {
                                Text(String(localized: String.LocalizationValue(profile.sunSign.nameKey)))
                                Text("•")
                                Text(String(localized: String.LocalizationValue(profile.risingSign.nameKey)))
                            }
                            .font(AppTheme.Typography.body.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))

                            VStack(spacing: 4) {
                                Text(profile.birthDate.formatted(date: .long, time: .omitted))
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)

                                if let birthTime = profile.birthTime,
                                   let birthTimeText = formattedBirthTime(birthTime) {
                                    Text(birthTimeText)
                                        .font(AppTheme.Typography.body)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }

                            Text(profile.cityName)
                                .font(AppTheme.Typography.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)

                            Button(String(localized: "profile.reset")) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                    showResetConfirmation.toggle()
                                }
                            }
                            .buttonStyle(AstroGlassPrimaryButtonStyle(fullWidth: true))
                            .padding(.top, 6)

                            if showResetConfirmation {
                                VStack(spacing: 10) {
                                    Text(String(localized: "profile.reset.confirm.title"))
                                        .font(AppTheme.Typography.headlineBold)
                                        .foregroundStyle(.white.opacity(0.96))
                                        .multilineTextAlignment(.center)

                                    Text(String(localized: "profile.reset.confirm.message"))
                                        .font(AppTheme.Typography.footnote)
                                        .foregroundStyle(.white.opacity(0.86))
                                        .multilineTextAlignment(.center)

                                    HStack(spacing: 10) {
                                        Button(String(localized: "action.cancel"), role: .cancel) {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                                showResetConfirmation = false
                                            }
                                        }
                                        .buttonStyle(AstroGlassSecondaryButtonStyle())

                                        Button(String(localized: "profile.reset.confirm.cta"), role: .destructive) {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                                showResetConfirmation = false
                                            }
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                                                model.hasCompletedOnboarding = false
                                            }
                                        }
                                        .buttonStyle(AstroGlassPrimaryButtonStyle(fullWidth: false))
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(.white.opacity(0.18), lineWidth: 1)
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: cardMaxWidth)
                .padding(.horizontal, sidePadding)
                .padding(.top, 16)

                GlassCard(style: .standard) {
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(String(localized: "profile.notifications"), isOn: Bindable(model).notificationsEnabled)
                            .tint(AppTheme.Colors.accentLilac)
                        Text(String(localized: "profile.notifications.subtitle"))
                            .font(AppTheme.Typography.footnote)
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: cardMaxWidth)
                .padding(.horizontal, sidePadding)
                .padding(.top, 12)

                Spacer(minLength: 0)
            }
            .safeAreaPadding(.top, 16)
            .safeAreaPadding(.bottom, 24)
        }
        .navigationTitle("")
        .toolbar(.hidden, for: .navigationBar)
    }

    private func formattedBirthTime(_ birthTime: BirthTime) -> String? {
        let components = DateComponents(hour: birthTime.hour, minute: birthTime.minute)
        guard let date = Calendar.current.date(from: components) else { return nil }
        return date.formatted(date: .omitted, time: .shortened)
    }
}
