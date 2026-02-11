import Foundation

struct HoroscopeService {
    func weeklyHoroscope(for sunSign: ZodiacSign, risingSign: ZodiacSign, weekOfYear: Int) -> Horoscope {
        let languageCode = preferredLanguageCode()
        let content = loadContent(for: languageCode) ?? loadContent(for: "en") ?? .empty

        let themeIndex = abs(weekOfYear - 1) % max(1, content.themes.count)
        let theme = content.themes[safe: themeIndex] ?? ""
        let sunName = localized(sunSign.nameKey)
        let risingName = localized(risingSign.nameKey)
        let sunCore = content.sunCore[sunSign.rawValue] ?? ""
        let risingStyle = content.risingStyle[risingSign.rawValue] ?? ""

        let profileBase = interpolate(
            content.profileBaseTemplate,
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

        let opening = interpolate(content.openingTemplate, context)
        let manifestation = interpolate(content.manifestationTemplate, context)
        let advice = interpolate(content.adviceTemplate, context)
        let closing = interpolate(content.closingTemplate, context)

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

    private func localized(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }

    private var resourceBundles: [Bundle] {
        [Bundle.main, Bundle(for: BundleToken.self)]
    }
}

private final class BundleToken {}

private struct HoroscopeEngineContent: Codable {
    let openingTemplate: String
    let manifestationTemplate: String
    let adviceTemplate: String
    let closingTemplate: String
    let profileBaseTemplate: String
    let themes: [String]
    let sunCore: [String: String]
    let risingStyle: [String: String]
}

private extension HoroscopeEngineContent {
    static let empty = HoroscopeEngineContent(
        openingTemplate: "",
        manifestationTemplate: "",
        adviceTemplate: "",
        closingTemplate: "",
        profileBaseTemplate: "",
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
