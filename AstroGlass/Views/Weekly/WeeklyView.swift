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

    private var stableWeeklyHoroscope: Horoscope? {
        if let cached = model.weeklyHoroscope {
            return cached
        }
        guard let profile = model.profile else { return nil }
        let currentWeek = Calendar.current.component(.weekOfYear, from: Date())
        return model.horoscopeService.weeklyHoroscope(
            for: profile.sunSign,
            risingSign: profile.risingSign,
            weekOfYear: currentWeek
        )
    }

    private var weeklyFooterText: String {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        let footerIndex = (max(week, 1) - 1) % 15 + 1
        let key = "weekly.footer.\(footerIndex)"
        let resolved = Bundle.main.localizedString(forKey: key, value: key, table: nil)
        if resolved == key {
            return String(localized: "weekly.footer")
        }
        return resolved
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 0)

                    Text("AstroGlass")
                        .font(AppTheme.Typography.displaySerif(46))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: cardMaxWidth, alignment: .center)
                        .padding(.horizontal, sidePadding)

                    Group {
                        if let profile = model.profile {
                            heroCard(profile)
                        } else {
                            heroPlaceholderCard()
                        }
                    }
                    .frame(maxWidth: cardMaxWidth)
                    .padding(.horizontal, sidePadding)

                    forecastCard()
                    .frame(maxWidth: cardMaxWidth)
                    .padding(.horizontal, sidePadding)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .onAppear {
            if model.profile != nil {
                model.refreshHoroscope()
            }
        }
        .onChange(of: model.profile?.id) { _, _ in
            if model.profile != nil {
                model.refreshHoroscope()
            }
        }
    }

    private func heroCard(_ profile: UserProfile) -> some View {
        GlassCard(style: .hero) {
            VStack(spacing: 12) {
                Text(String(localized: "weekly.title"))
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.white.opacity(0.95))

                GlowSymbolView(symbol: profile.sunSign.symbol, size: 94)

                Text("\(String(localized: "weekly.sun.full")): \(String(localized: String.LocalizationValue(profile.sunSign.nameKey)))\n\(String(localized: "weekly.asc.full")): \(String(localized: String.LocalizationValue(profile.risingSign.nameKey)))")
                    .font(AppTheme.Typography.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.96))
                    .fixedSize(horizontal: false, vertical: true)

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
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func heroPlaceholderCard() -> some View {
        GlassCard(style: .hero) {
            VStack(spacing: 12) {
                Text(String(localized: "weekly.title"))
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.white.opacity(0.95))
                GlowSymbolView(symbol: "✦", size: 94)
                Text("\(String(localized: "weekly.sun.full")): —\n\(String(localized: "weekly.asc.full")): —")
                    .font(AppTheme.Typography.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.96))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func forecastCard() -> some View {
        GlassCard(style: .standard) {
            VStack(alignment: .leading, spacing: 14) {
                Text(String(localized: "weekly.forecast.title"))
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.white.opacity(0.96))

                if model.isLoadingHoroscope {
                    ShimmerPlaceholderView()
                        .frame(height: 140)
                } else if let horoscope = stableWeeklyHoroscope {
                    ForEach(horoscope.paragraphs.indices, id: \.self) { i in
                        Text(horoscope.paragraphs[i])
                            .foregroundStyle(.white.opacity(0.94))
                            .font(AppTheme.Typography.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(weeklyFooterText)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                } else {
                    ShimmerPlaceholderView()
                        .frame(height: 140)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
