import SwiftUI

struct WeeklyView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var cardMaxWidth: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.cardMaxWidthRegular : AppTheme.Metrics.cardMaxWidthCompact
    }

    private var sidePadding: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.sidePaddingRegular : AppTheme.Metrics.sidePaddingCompact
    }

    private var forecastSidePadding: CGFloat {
        max(10, sidePadding - 8)
    }

    private var forecastBottomPadding: CGFloat {
        horizontalSizeClass == .regular ? 96 : 132
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            VStack(spacing: 12) {
                VStack(spacing: -2) {
                    Text("Astro Zodiac")
                        .font(AppTheme.Typography.displaySerif(40))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.14))
                            .frame(width: 86, height: 86)
                            .blur(radius: 8)

                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 74, height: 74)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.22), lineWidth: 1)
                            )

                        Text("AI")
                            .font(AppTheme.Typography.displaySerif(32))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .shadow(color: AppTheme.Colors.nebulaViolet.opacity(0.35), radius: 16, x: 0, y: 8)
                }
                .frame(maxWidth: cardMaxWidth, alignment: .center)
                .padding(.horizontal, sidePadding)

                Group {
                    if let profile = model.profile {
                        heroCard(profile)
                    }
                }
                .padding(.top, -8)
                .padding(.bottom, 18)
                .frame(maxWidth: cardMaxWidth)
                .padding(.horizontal, sidePadding)

                if !model.isLoadingAIModel, model.weeklyHoroscope != nil {
                    ScrollView {
                        forecastCard()
                            .frame(maxWidth: cardMaxWidth)
                            .padding(.horizontal, forecastSidePadding)
                            .padding(.bottom, forecastBottomPadding)
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.opacity)
                } else {
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaPadding(.top, 24)
        }
    }

    private func heroCard(_ profile: UserProfile) -> some View {
        VStack(spacing: 4) {
            Text("\(String(localized: "weekly.sun.full")): \(String(localized: String.LocalizationValue(profile.sunSign.nameKey)))\n\(String(localized: "weekly.asc.full")): \(String(localized: String.LocalizationValue(profile.risingSign.nameKey)))")
                .font(AppTheme.Typography.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.96))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            if !profile.hasExactTime {
                Text(String(localized: "weekly.rising.approx"))
                    .font(AppTheme.Typography.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )
            }

            GlowSymbolView(imageName: profile.sunSign.assetName, size: 72, isAnimated: false)
                .padding(.top, 4)
                .padding(.bottom, -8)
        }
        .frame(maxWidth: .infinity)
    }

    private func forecastCard() -> some View {
        GlassCard(style: .standard) {
            let forecastText = model.weeklyHoroscope?.paragraphs.first ?? ""
            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "weekly.forecast.title"))
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(.white.opacity(0.96))
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(justifiedForecastText(forecastText))
                    .foregroundStyle(.white.opacity(0.94))
                    .font(.system(size: 19, weight: .regular, design: .default))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, -8)
            .frame(maxWidth: .infinity)
        }
    }

    private func justifiedForecastText(_ text: String) -> AttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        let attributed = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        return AttributedString(attributed)
    }
}

#Preview("Weekly Loaded") {
    let model = AppModel()
    model.profile = UserProfile(
        id: UUID(),
        name: "Albert",
        birthDate: .now,
        birthTime: BirthTime(hour: 17, minute: 10),
        cityName: "Vilafranca del Penedès, ES",
        latitude: 41.3462,
        longitude: 1.6971,
        timeZoneId: "Europe/Madrid",
        sunSign: .scorpio,
        risingSign: .taurus
    )
    model.weeklyHoroscope = Horoscope(
        sign: .scorpio,
        weekOfYear: Calendar.current.component(.weekOfYear, from: .now),
        paragraphs: [
            "Esta semana se mueve con un tono más claro de lo habitual y te conviene empezar por lo esencial, no por lo urgente. Si eliges una sola prioridad fuerte para lunes y martes, el resto de piezas encajará con menos fricción. En la parte central de la semana, una conversación que has pospuesto puede abrir una vía muy útil si llegas con calma, datos concretos y un límite bien explicado. No necesitas justificarte de más: necesitas ejecutar con consistencia. A nivel práctico, protege bloques de trabajo profundo, reduce cambios de contexto y deja espacio de recuperación para no llegar al jueves agotado. Si aparece tensión, pausa antes de responder y vuelve con una decisión limpia. Al cerrar la semana, te sentirás más ordenado, con menos ruido mental y con la sensación real de haber recuperado dirección."
        ]
    )
    model.isLoadingHoroscope = false
    return WeeklyView()
        .environment(model)
}

#Preview("Weekly Loading") {
    let model = AppModel()
    model.profile = UserProfile(
        id: UUID(),
        name: "Albert",
        birthDate: .now,
        birthTime: BirthTime(hour: 17, minute: 10),
        cityName: "Vilafranca del Penedès, ES",
        latitude: 41.3462,
        longitude: 1.6971,
        timeZoneId: "Europe/Madrid",
        sunSign: .scorpio,
        risingSign: .taurus
    )
    model.isLoadingHoroscope = true
    return WeeklyView()
        .environment(model)
}
