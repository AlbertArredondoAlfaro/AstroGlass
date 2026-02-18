import SwiftUI

struct SignsGridView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var namespace

    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 3 : 2
        return Array(
            repeating: GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 16),
            count: count
        )
    }

    private var sidePadding: CGFloat {
        horizontalSizeClass == .regular ? AppTheme.Metrics.sidePaddingRegular : AppTheme.Metrics.screenPadding
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(String(localized: "signs.title"))
                            .font(AppTheme.Typography.displaySerif(34))
                            .foregroundStyle(.white.opacity(0.96))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 6)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(ZodiacSign.allCases) { sign in
                                NavigationLink(value: sign) {
                                    SignGridCard(sign: sign, namespace: namespace)
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, sidePadding)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .clipped()
            }
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ZodiacSign.self) { sign in
                SignDetailView(sign: sign, namespace: namespace)
            }
        }
    }
}

private struct SignGridCard: View {
    let sign: ZodiacSign
    let namespace: Namespace.ID

    var body: some View {
        GlassCard(style: .grid) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(.white.opacity(0.16))
                    .frame(width: 90, height: 90)
                    .blur(radius: 16)
                    .offset(x: 26, y: -34)

                VStack(spacing: 12) {
                    GlowSymbolView(imageName: sign.assetName, size: 64, isAnimated: false)
                        .matchedGeometryEffect(id: sign.rawValue, in: namespace)

                    Text(String(localized: String.LocalizationValue(sign.nameKey)))
                        .font(AppTheme.Typography.title3)
                        .foregroundStyle(.white.opacity(0.97))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.88)

                    Text(String(localized: String.LocalizationValue(sign.elementKey)))
                        .font(AppTheme.Typography.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.72))
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, minHeight: 174)
        }
    }
}
