import SwiftUI

struct AstroGlassPrimaryButtonStyle: ButtonStyle {
    var fullWidth = false

    func makeBody(configuration: Configuration) -> some View {
        styledLabel(configuration: configuration)
    }

    @ViewBuilder
    private func styledLabel(configuration: Configuration) -> some View {
        let label = configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(minHeight: AppTheme.Metrics.primaryButtonHeight)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(.ultraThinMaterial, in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.white.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 14, x: 0, y: 8)
            .opacity(configuration.isPressed ? 0.86 : 1)

        label
    }
}

struct AstroGlassSecondaryButtonStyle: ButtonStyle {
    var fullWidth = false

    func makeBody(configuration: Configuration) -> some View {
        styledLabel(configuration: configuration)
    }

    @ViewBuilder
    private func styledLabel(configuration: Configuration) -> some View {
        let label = configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.94))
            .padding(.horizontal, 16)
            .frame(minHeight: AppTheme.Metrics.primaryButtonHeight)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(.thinMaterial, in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.88 : 1)

        label
    }
}
