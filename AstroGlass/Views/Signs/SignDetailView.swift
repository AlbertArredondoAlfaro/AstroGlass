import SwiftUI

struct SignDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let sign: ZodiacSign

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
                GlassCard(style: .detail) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Spacer(minLength: 0)
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .frame(width: 30, height: 30)
                                    .background(.thinMaterial, in: Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        VStack(spacing: 8) {
                            GlowSymbolView(imageName: sign.assetName, size: 94, isAnimated: false)

                            Text(localized(sign.nameKey))
                                .font(AppTheme.Typography.title2)
                                .foregroundStyle(.white.opacity(0.97))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            Text("\(localized(sign.elementKey)) · \(localized(sign.rulerKey))")
                                .font(AppTheme.Typography.footnote.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.78))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)

                        Divider()
                            .overlay(.white.opacity(0.2))

                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                SignDetailSection(
                                    title: String(localized: "sign.detail.strengths"),
                                    value: localized(sign.strengthsKey)
                                )
                                SignDetailSection(
                                    title: String(localized: "sign.detail.weaknesses"),
                                    value: localized(sign.weaknessesKey)
                                )
                                SignDetailSection(
                                    title: String(localized: "sign.detail.love"),
                                    value: localized(sign.loveKey)
                                )
                                SignDetailSection(
                                    title: String(localized: "sign.detail.career"),
                                    value: localized(sign.careerKey)
                                )
                                SignDetailSection(
                                    title: String(localized: "sign.detail.color"),
                                    value: localized(sign.colorKey)
                                )
                                SignDetailSection(
                                    title: String(localized: "sign.detail.stone"),
                                    value: localized(sign.stoneKey)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .scrollIndicators(.hidden)
                        .frame(minHeight: 220, maxHeight: 320)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: cardMaxWidth)
                .padding(.horizontal, sidePadding)
                .padding(.top, 16)

                Spacer(minLength: 0)
            }
            .safeAreaPadding(.bottom, 24)
        }
    }

    private func localized(_ key: String) -> String {
        String(localized: String.LocalizationValue(key))
    }
}

private struct SignDetailSection: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(AppTheme.Typography.headlineBold)
                .foregroundStyle(.white.opacity(0.95))

            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundStyle(.white.opacity(0.86))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
