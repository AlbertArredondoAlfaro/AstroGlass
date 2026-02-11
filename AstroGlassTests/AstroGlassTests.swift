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
}
