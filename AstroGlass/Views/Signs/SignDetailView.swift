import SwiftUI

struct SignDetailView: View {
    let sign: ZodiacSign
    let namespace: Namespace.ID

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GlassCard(style: .detail) {
                    VStack(spacing: 8) {
                        GlowSymbolView(symbol: sign.symbol, size: 88)
                            .matchedGeometryEffect(id: sign.rawValue, in: namespace)
                        Text(String(localized: String.LocalizationValue(sign.nameKey)))
                            .font(AppTheme.Typography.title)
                        Text(String(localized: String.LocalizationValue(sign.elementKey)))
                            .foregroundStyle(.secondary)
                        Text(String(localized: String.LocalizationValue(sign.rulerKey)))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                detailCard(String(localized: "sign.detail.strengths"), sign.strengthsKey)
                detailCard(String(localized: "sign.detail.weaknesses"), sign.weaknessesKey)
                detailCard(String(localized: "sign.detail.love"), sign.loveKey)
                detailCard(String(localized: "sign.detail.career"), sign.careerKey)
                detailCard(String(localized: "sign.detail.color"), sign.colorKey)
                detailCard(String(localized: "sign.detail.stone"), sign.stoneKey)
            }
            .padding(AppTheme.Metrics.screenPadding)
        }
        .navigationTitle(String(localized: String.LocalizationValue(sign.nameKey)))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailCard(_ title: String, _ valueKey: String) -> some View {
        GlassCard(style: .standard) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                Text(String(localized: String.LocalizationValue(valueKey)))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
