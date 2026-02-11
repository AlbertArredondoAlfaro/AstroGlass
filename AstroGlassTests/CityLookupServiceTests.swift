import XCTest
@testable import AstroGlass

final class CityLookupServiceTests: XCTestCase {
    func testResolveCityTrimsInputAndReturnsMappedCity() async throws {
        let sut = CityLookupService { query in
            XCTAssertEqual(query, "Barcelona")
            return [
                .init(
                    name: nil,
                    locality: "Barcelona",
                    subLocality: nil,
                    country: "Spain",
                    latitude: 41.3874,
                    longitude: 2.1686,
                    timeZoneId: "Europe/Madrid"
                )
            ]
        }

        let city = try await sut.resolveCity(named: "  Barcelona  ")

        XCTAssertEqual(city.name, "Barcelona")
        XCTAssertEqual(city.country, "Spain")
        XCTAssertEqual(city.latitude, 41.3874, accuracy: 0.0001)
        XCTAssertEqual(city.longitude, 2.1686, accuracy: 0.0001)
        XCTAssertEqual(city.timeZoneId, "Europe/Madrid")
    }

    func testResolveCityThrowsEmptyInput() async {
        let sut = CityLookupService { _ in
            XCTFail("Geocoder should not be called for empty input")
            return []
        }

        do {
            _ = try await sut.resolveCity(named: "   ")
            XCTFail("Expected emptyInput error")
        } catch let error as CityLookupService.LookupError {
            XCTAssertEqual(error, .emptyInput)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testResolveCityThrowsNotFoundWhenNoCoordinates() async {
        let sut = CityLookupService { _ in
            [
                .init(
                    name: "Unknown",
                    locality: nil,
                    subLocality: nil,
                    country: nil,
                    latitude: nil,
                    longitude: nil,
                    timeZoneId: nil
                )
            ]
        }

        do {
            _ = try await sut.resolveCity(named: "Nope")
            XCTFail("Expected notFound error")
        } catch let error as CityLookupService.LookupError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testResolveCityMapsLookupErrors() async {
        let expected: CityLookupService.LookupError = .network
        let sut = CityLookupService { _ in
            throw expected
        }

        do {
            _ = try await sut.resolveCity(named: "Paris")
            XCTFail("Expected network error")
        } catch let error as CityLookupService.LookupError {
            XCTAssertEqual(error, .network)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
