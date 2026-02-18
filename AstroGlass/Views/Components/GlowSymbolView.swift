import SwiftUI

struct GlowSymbolView: View {
    let symbol: String?
    let imageName: String?
    let size: CGFloat
    let isAnimated: Bool

    init(symbol: String, size: CGFloat, isAnimated: Bool = true) {
        self.symbol = symbol
        self.imageName = nil
        self.size = size
        self.isAnimated = isAnimated
    }

    init(imageName: String, size: CGFloat, isAnimated: Bool = true) {
        self.symbol = nil
        self.imageName = imageName
        self.size = size
        self.isAnimated = isAnimated
    }

    var body: some View {
        Group {
            if isAnimated {
                symbolContent
                    .phaseAnimator([0, 1]) { content, phase in
                        content
                            .scaleEffect(phase == 0 ? 1 : 1.06)
                            .rotationEffect(.degrees(phase == 0 ? -2 : 2))
                    } animation: { _ in
                        .easeInOut(duration: 3).repeatForever(autoreverses: true)
                    }
            } else {
                symbolContent
            }
        }
            .shadow(color: AppTheme.Colors.nebulaViolet.opacity(0.7), radius: 24)
            .shadow(color: AppTheme.Colors.nebulaBlue.opacity(0.5), radius: 40)
    }

    @ViewBuilder
    private var symbolContent: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .colorMultiply(.white)
        } else if let symbol {
            Text(symbol)
                .font(AppTheme.Typography.displaySerif(size, weight: .regular))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, AppTheme.Colors.nebulaViolet.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}
