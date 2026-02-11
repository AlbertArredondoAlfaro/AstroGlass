import SwiftUI

struct WeeklyView: View {
    @Environment(AppModel.self) private var model
    @State private var burstTrigger = 0
    @State private var expanded = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Metrics.sectionSpacing) {
                if let profile = model.profile {
                    heroCard(profile)
                }

                if model.isLoadingHoroscope {
                    ShimmerPlaceholderView()
                        .frame(height: 220)
                } else if let horoscope = model.weeklyHoroscope {
                    GlassCard(style: .standard) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(horoscope.paragraphs.indices, id: \.self) { i in
                                Text(horoscope.paragraphs[i])
                                    .foregroundStyle(.white.opacity(0.94))
                                    .font(AppTheme.Typography.body)
                            }
                            if expanded {
                                Text(String(localized: "weekly.footer"))
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button(expanded ? String(localized: "action.collapse") : String(localized: "action.readfull")) {
                    let wasExpanded = expanded
                    withAnimation(.spring(response: 0.58, dampingFraction: 0.62)) {
                        expanded.toggle()
                        burstTrigger += 1
                    }
                    if !wasExpanded {
                        model.adService.showInterstitialIfAllowed()
                    }
                }
                .buttonStyle(AstroGlassPrimaryButtonStyle())
            }
            .padding(AppTheme.Metrics.screenPadding)
        }
        .overlay(ParticleBurstView(trigger: burstTrigger))
        .onAppear { model.refreshHoroscope() }
    }

    private func heroCard(_ profile: UserProfile) -> some View {
        GlassCard(style: .hero) {
            VStack(spacing: 14) {
                GlowSymbolView(symbol: profile.sunSign.symbol, size: 94)
                Text(String(localized: "weekly.title"))
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.secondary)

                Text(String(localized: String.LocalizationValue(profile.sunSign.nameKey)))
                    .font(AppTheme.Typography.displaySerif(34, weight: .bold))

                Text(String(localized: "weekly.rising"))
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)

                Text(String(localized: String.LocalizationValue(profile.risingSign.nameKey)))
                    .font(AppTheme.Typography.title3)

                if !profile.hasExactTime {
                    Text(String(localized: "weekly.rising.approx"))
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollTransition(.interactive, axis: .vertical) { content, phase in
            content.offset(y: -phase.value * 16)
        }
    }
}
