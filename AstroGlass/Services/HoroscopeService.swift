import Foundation

struct HoroscopeService {
    func weeklyHoroscope(
        for sunSign: ZodiacSign,
        risingSign: ZodiacSign,
        weekOfYear: Int,
        yearForWeekOfYear: Int,
        profileID: UUID
    ) async -> Horoscope {
        let forecast = await CoreMLForecastService.shared.generateWeeklyForecast(
            sunSign: sunSign,
            risingSign: risingSign,
            weekOfYear: weekOfYear,
            yearForWeekOfYear: yearForWeekOfYear,
            profileID: profileID
        )
        return Horoscope(sign: sunSign, weekOfYear: weekOfYear, paragraphs: [forecast])
    }
}
