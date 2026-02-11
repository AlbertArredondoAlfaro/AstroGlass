import SwiftUI

struct GlowSymbolView: View {
    let symbol: String
    let size: CGFloat

    var body: some View {
        Text(symbol)
            .font(AppTheme.Typography.displaySerif(size, weight: .regular))
            .foregroundStyle(
                LinearGradient(
                    colors: [.white, AppTheme.Colors.nebulaViolet.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: AppTheme.Colors.nebulaViolet.opacity(0.7), radius: 24)
            .shadow(color: AppTheme.Colors.nebulaBlue.opacity(0.5), radius: 40)
            .phaseAnimator([0, 1]) { content, phase in
                content
                    .scaleEffect(phase == 0 ? 1 : 1.06)
                    .rotationEffect(.degrees(phase == 0 ? -2 : 2))
            } animation: { _ in
                .easeInOut(duration: 3).repeatForever(autoreverses: true)
            }
    }
}
