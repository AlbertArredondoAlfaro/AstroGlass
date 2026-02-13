import Foundation

struct HoroscopeService {
    func weeklyHoroscope(for sunSign: ZodiacSign, risingSign: ZodiacSign, weekOfYear: Int) -> Horoscope {
        let languageCode = preferredLanguageCode()
        let content = loadContent(for: languageCode) ?? loadContent(for: "en") ?? .empty

        let themeIndex = abs(weekOfYear - 1) % max(1, content.themes.count)
        let theme = content.themes[safe: themeIndex] ?? ""
        let sunName = localized(sunSign.nameKey)
        let risingName = localized(risingSign.nameKey)
        let seed = deterministicSeed(
            weekOfYear: weekOfYear,
            sunSign: sunSign,
            risingSign: risingSign,
            languageCode: languageCode
        )
        let sunCore = pickVariant(content.sunCore[sunSign.rawValue] ?? [], seed: seed, salt: 101)
        let risingStyle = pickVariant(content.risingStyle[risingSign.rawValue] ?? [], seed: seed, salt: 131)
        let profileBaseTemplate = pickVariant(content.profileBaseTemplates, seed: seed, salt: 151)

        let profileBase = interpolate(
            profileBaseTemplate,
            [
                "SUN_CORE": sunCore,
                "RISING_STYLE": risingStyle
            ]
        )

        let context: [String: String] = [
            "THEME": theme,
            "SUN_NAME": sunName,
            "RISING_NAME": risingName,
            "PROFILE_BASE": profileBase
        ]

        let opening = interpolate(pickTemplate(content.openingTemplates, seed: seed, salt: 11), context)
        let manifestation = interpolate(pickTemplate(content.manifestationTemplates, seed: seed, salt: 29), context)
        let advice = interpolate(pickTemplate(content.adviceTemplates, seed: seed, salt: 47), context)
        let closing = interpolate(pickTemplate(content.closingTemplates, seed: seed, salt: 83), context)

        return Horoscope(sign: sunSign, weekOfYear: weekOfYear, paragraphs: [opening, manifestation, advice, closing])
    }

    private func preferredLanguageCode() -> String {
        let lang = Locale.preferredLanguages.first?.lowercased() ?? "en"
        if lang.hasPrefix("es") { return "es" }
        if lang.hasPrefix("ca") { return "ca" }
        if lang.hasPrefix("fr") { return "fr" }
        if lang.hasPrefix("de") { return "de" }
        return "en"
    }

    private func loadContent(for languageCode: String) -> HoroscopeEngineContent? {
        for bundle in resourceBundles {
            let resourceName = "horoscope_engine_\(languageCode)"
            let directURL = bundle.url(forResource: resourceName, withExtension: "json")
            let subdirURL = bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "HoroscopeEngine")
            guard let url = directURL ?? subdirURL,
                  let data = try? Data(contentsOf: url),
                  let decoded = try? JSONDecoder().decode(HoroscopeEngineContent.self, from: data)
            else {
                continue
            }
            return decoded
        }
        return nil
    }

    private func interpolate(_ template: String, _ values: [String: String]) -> String {
        values.reduce(template) { partial, item in
            partial.replacingOccurrences(of: "[\(item.key)]", with: item.value)
        }
    }

    private func pickTemplate(_ templates: [String], seed: Int, salt: Int) -> String {
        guard !templates.isEmpty else { return "" }
        let index = abs(seed &+ salt) % templates.count
        return templates[index]
    }

    private func pickVariant(_ variants: [String], seed: Int, salt: Int) -> String {
        guard !variants.isEmpty else { return "" }
        let index = abs(seed &+ salt) % variants.count
        return variants[index]
    }

    private func deterministicSeed(
        weekOfYear: Int,
        sunSign: ZodiacSign,
        risingSign: ZodiacSign,
        languageCode: String
    ) -> Int {
        let sunIndex = ZodiacSign.allCases.firstIndex(of: sunSign) ?? 0
        let risingIndex = ZodiacSign.allCases.firstIndex(of: risingSign) ?? 0

        var seed = 17
        seed = seed &* 31 &+ weekOfYear
        seed = seed &* 31 &+ sunIndex
        seed = seed &* 31 &+ risingIndex
        for scalar in languageCode.unicodeScalars {
            seed = seed &* 31 &+ Int(scalar.value)
        }
        return seed
    }

    private func localized(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }

    private var resourceBundles: [Bundle] {
        [Bundle.main, Bundle(for: BundleToken.self)]
    }
}

private final class BundleToken {}

private struct HoroscopeEngineContent: Codable {
    let openingTemplates: [String]
    let manifestationTemplates: [String]
    let adviceTemplates: [String]
    let closingTemplates: [String]
    let profileBaseTemplates: [String]
    let themes: [String]
    let sunCore: [String: [String]]
    let risingStyle: [String: [String]]
}

private extension HoroscopeEngineContent {
    static let empty = HoroscopeEngineContent(
        openingTemplates: [],
        manifestationTemplates: [],
        adviceTemplates: [],
        closingTemplates: [],
        profileBaseTemplates: [],
        themes: [],
        sunCore: [:],
        risingStyle: [:]
    )
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
