import Foundation

enum AscendantCalculator {
    static func risingSign(
        birthDate: Date,
        birthTime: BirthTime?,
        latitude: Double,
        longitude: Double,
        timeZoneId: String
    ) -> ZodiacSign {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneId) ?? .current

        let dateParts = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let time = birthTime ?? BirthTime(hour: 12, minute: 0)

        var components = DateComponents()
        components.year = dateParts.year
        components.month = dateParts.month
        components.day = dateParts.day
        components.hour = time.hour
        components.minute = time.minute

        let localDate = calendar.date(from: components) ?? birthDate
        let julianDay = localDate.timeIntervalSince1970 / 86400 + 2440587.5

        let d = julianDay - 2451545.0
        var gmst = 18.697374558 + 24.06570982441908 * d
        gmst = gmst.truncatingRemainder(dividingBy: 24)
        if gmst < 0 { gmst += 24 }

        var lst = gmst + longitude / 15.0
        lst = lst.truncatingRemainder(dividingBy: 24)
        if lst < 0 { lst += 24 }

        let epsilon = deg2rad(23.439291)
        let theta = deg2rad(lst * 15)
        let phi = deg2rad(latitude)

        let numerator = -cos(theta)
        let denominator = sin(theta) * cos(epsilon) + tan(phi) * sin(epsilon)
        var asc = atan2(numerator, denominator)
        var ascDegrees = rad2deg(asc)
        if ascDegrees < 0 { ascDegrees += 360 }
        // This formula returns the opposite horizon point in our coordinate setup,
        // so rotate 180 degrees to obtain the actual Ascendant (eastern horizon).
        ascDegrees = (ascDegrees + 180).truncatingRemainder(dividingBy: 360)

        let index = Int(ascDegrees / 30) % 12
        return ZodiacSign.allCases[index]
    }

    private static func deg2rad(_ value: Double) -> Double { value * .pi / 180 }
    private static func rad2deg(_ value: Double) -> Double { value * 180 / .pi }
}
