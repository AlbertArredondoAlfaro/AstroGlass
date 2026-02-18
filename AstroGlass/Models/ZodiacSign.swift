import Foundation

enum ZodiacSign: String, CaseIterable, Codable, Identifiable {
    case aries, taurus, gemini, cancer, leo, virgo, libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .aries: "♈︎"
        case .taurus: "♉︎"
        case .gemini: "♊︎"
        case .cancer: "♋︎"
        case .leo: "♌︎"
        case .virgo: "♍︎"
        case .libra: "♎︎"
        case .scorpio: "♏︎"
        case .sagittarius: "♐︎"
        case .capricorn: "♑︎"
        case .aquarius: "♒︎"
        case .pisces: "♓︎"
        }
    }

    var assetName: String {
        "Zodiac\(rawValue.prefix(1).uppercased())\(rawValue.dropFirst())"
    }

    var nameKey: String { "sign.\(rawValue).name" }
    var strengthsKey: String { "sign.\(rawValue).strengths" }
    var weaknessesKey: String { "sign.\(rawValue).weaknesses" }
    var loveKey: String { "sign.\(rawValue).love" }
    var careerKey: String { "sign.\(rawValue).career" }
    var colorKey: String { "sign.\(rawValue).color" }
    var stoneKey: String { "sign.\(rawValue).stone" }
    var giftKey: String { "sign.\(rawValue).gift" }
    var shadowKey: String { "sign.\(rawValue).shadow" }
    var mantraKey: String { "sign.\(rawValue).mantra" }

    var elementKey: String {
        switch self {
        case .aries, .leo, .sagittarius: "element.fire"
        case .taurus, .virgo, .capricorn: "element.earth"
        case .gemini, .libra, .aquarius: "element.air"
        case .cancer, .scorpio, .pisces: "element.water"
        }
    }

    var rulerKey: String {
        switch self {
        case .aries: "ruler.mars"
        case .taurus: "ruler.venus"
        case .gemini: "ruler.mercury"
        case .cancer: "ruler.moon"
        case .leo: "ruler.sun"
        case .virgo: "ruler.mercury"
        case .libra: "ruler.venus"
        case .scorpio: "ruler.pluto"
        case .sagittarius: "ruler.jupiter"
        case .capricorn: "ruler.saturn"
        case .aquarius: "ruler.uranus"
        case .pisces: "ruler.neptune"
        }
    }
}
