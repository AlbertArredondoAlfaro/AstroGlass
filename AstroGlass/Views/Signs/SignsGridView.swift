import SwiftUI

struct SignsGridView: View {
    @Namespace private var namespace
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(ZodiacSign.allCases) { sign in
                        NavigationLink(value: sign) {
                            GlassCard(style: .grid) {
                                VStack(spacing: 8) {
                                    GlowSymbolView(symbol: sign.symbol, size: 56)
                                        .matchedGeometryEffect(id: sign.rawValue, in: namespace)
                                    Text(String(localized: String.LocalizationValue(sign.nameKey)))
                                        .font(AppTheme.Typography.headline)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppTheme.Metrics.screenPadding)
            }
            .navigationTitle(String(localized: "signs.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ZodiacSign.self) { sign in
                SignDetailView(sign: sign, namespace: namespace)
            }
        }
    }
}
