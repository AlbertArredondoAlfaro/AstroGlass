import SwiftUI

enum AstroGlassCardStyle {
    case onboarding
    case hero
    case profile
    case grid
    case detail
    case standard

    var cornerRadius: CGFloat {
        switch self {
        case .onboarding:
            return AppTheme.Metrics.cardCornerRadius
        case .hero:
            return AppTheme.Metrics.cardCornerRadius
        case .profile:
            return AppTheme.Metrics.mediumCardCornerRadius
        case .grid:
            return AppTheme.Metrics.smallCardCornerRadius
        case .detail:
            return AppTheme.Metrics.detailCardCornerRadius
        case .standard:
            return AppTheme.Metrics.mediumCardCornerRadius
        }
    }
}

extension GlassCard {
    init(style: AstroGlassCardStyle, @ViewBuilder content: () -> Content) {
        self.init(cornerRadius: style.cornerRadius, content: content)
    }
}
