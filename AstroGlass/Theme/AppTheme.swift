import SwiftUI

enum AppTheme {
    enum Colors {
        static let accentLilac = Color(red: 0.63, green: 0.46, blue: 0.96)

        static let cosmicGradientTop = Color(red: 0.05, green: 0.04, blue: 0.12)
        static let cosmicGradientMiddle = Color(red: 0.08, green: 0.04, blue: 0.20)
        static let cosmicGradientBottom = Color(red: 0.14, green: 0.06, blue: 0.28)

        static let nebulaViolet = Color.purple
        static let nebulaIndigo = Color.indigo
        static let nebulaBlue = Color.blue
    }

    enum Metrics {
        static let cardCornerRadius: CGFloat = 34
        static let mediumCardCornerRadius: CGFloat = 30
        static let smallCardCornerRadius: CGFloat = 26
        static let detailCardCornerRadius: CGFloat = 32
        static let fieldCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 24
        static let cardMaxWidthCompact: CGFloat = 340
        static let cardMaxWidthRegular: CGFloat = 540
        static let sidePaddingCompact: CGFloat = 8
        static let sidePaddingRegular: CGFloat = 72
        static let primaryButtonHeight: CGFloat = 54
        static let textFieldHeight: CGFloat = 50
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 16
        static let cardStackSpacing: CGFloat = 14
    }

    enum Typography {
        static func displaySerif(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
            .system(size: size, weight: weight, design: .serif)
        }

        static let title = Font.title.bold()
        static let title2 = Font.title2.bold()
        static let title3 = Font.title3.bold()
        static let headline = Font.headline
        static let headlineBold = Font.headline.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
        static let footnote = Font.footnote
    }
}
