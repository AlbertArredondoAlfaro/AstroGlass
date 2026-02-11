import Foundation

struct HoroscopeService {
    private let themesCount = 8

    func weeklyHoroscope(for sign: ZodiacSign, weekOfYear: Int) -> Horoscope {
        let name = String(localized: String.LocalizationValue(sign.nameKey))
        let element = String(localized: String.LocalizationValue(sign.elementKey))
        let ruler = String(localized: String.LocalizationValue(sign.rulerKey))
        let gift = String(localized: String.LocalizationValue(sign.giftKey))
        let shadow = String(localized: String.LocalizationValue(sign.shadowKey))
        let mantra = String(localized: String.LocalizationValue(sign.mantraKey))
        let theme = String(localized: String.LocalizationValue("weekly.theme.\(weekOfYear % themesCount + 1)"))

        let p1 = String.localizedStringWithFormat(String(localized: "horoscope.template.1"), name, element, ruler)
        let p2 = String.localizedStringWithFormat(String(localized: "horoscope.template.2"), gift, shadow, theme)
        let p3 = String.localizedStringWithFormat(String(localized: "horoscope.template.3"), mantra, name)

        return Horoscope(sign: sign, weekOfYear: weekOfYear, paragraphs: [p1, p2, p3])
    }
}
