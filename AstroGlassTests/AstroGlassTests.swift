import XCTest
@testable import AstroGlass

final class AstroGlassTests: XCTestCase {
    func testSunSignBoundaries() {
        let calendar = Calendar(identifier: .gregorian)
        let ariesDate = calendar.date(from: DateComponents(year: 2024, month: 3, day: 21))!
        let taurusDate = calendar.date(from: DateComponents(year: 2024, month: 4, day: 20))!

        XCTAssertEqual(ZodiacCalculator.sunSign(for: ariesDate), .aries)
        XCTAssertEqual(ZodiacCalculator.sunSign(for: taurusDate), .taurus)
    }

    func testAscendantForVilafrancaCase() {
        let calendar = Calendar(identifier: .gregorian)
        let birthDate = calendar.date(from: DateComponents(year: 1985, month: 11, day: 19))!
        let time = BirthTime(hour: 17, minute: 10)

        let rising = AscendantCalculator.risingSign(
            birthDate: birthDate,
            birthTime: time,
            latitude: 41.3462,
            longitude: 1.6971,
            timeZoneId: "Europe/Madrid"
        )

        XCTAssertEqual(rising, .taurus)
    }
}
