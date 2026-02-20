import SwiftUI

struct SignsGridView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedSign: ZodiacSign?

    private var columns: [GridItem] {
        [
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12),
            GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12)
        ]
    }

    private var cardMaxWidth: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.cardMaxWidthRegular : AppTheme.Metrics.cardMaxWidthCompact
    }

    private var sidePadding: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.sidePaddingRegular : AppTheme.Metrics.sidePaddingCompact
    }

    var body: some View {
        ZStack {
            CosmicBackgroundView()

            ScrollView {
                VStack(spacing: 0) {
                    Text(String(localized: "signs.title"))
                        .font(AppTheme.Typography.displaySerif(25))
                        .foregroundStyle(.white.opacity(0.96))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ZodiacSign.allCases) { sign in
                            Button {
                                selectedSign = sign
                            } label: {
                                SignGridCard(sign: sign)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: cardMaxWidth)
                .padding(.horizontal, sidePadding)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, 16)
            .safeAreaInset(edge: .bottom) {
                Color.clear
                    .frame(height: 88)
            }
        }
        .sheet(item: $selectedSign) { sign in
            SignDetailView(sign: sign)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct SignGridCard: View {
    let sign: ZodiacSign

    var body: some View {
        GlassCard(style: .grid) {
            VStack(spacing: 9) {
                GlowSymbolView(imageName: sign.assetName, size: 54, isAnimated: false)
                    .padding(.top, 2)

                Text(String(localized: String.LocalizationValue(sign.nameKey)))
                    .font(AppTheme.Typography.headlineBold)
                    .foregroundStyle(.white.opacity(0.97))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(String(localized: String.LocalizationValue(sign.elementKey)))
                    .font(AppTheme.Typography.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 146)
        }
        .frame(maxWidth: .infinity)
    }
}
