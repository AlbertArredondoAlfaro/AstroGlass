import CoreLocation
import Foundation

struct CityLookupService: Sendable {
    struct GeocodedPlace: Sendable {
        let name: String?
        let locality: String?
        let subLocality: String?
        let country: String?
        let latitude: Double?
        let longitude: Double?
        let timeZoneId: String?
    }

    enum LookupError: Error, Equatable {
        case emptyInput
        case notFound
        case network
        case denied
        case unknown

        var localizedKey: String {
            switch self {
            case .emptyInput:
                return "onboarding.city.error.empty"
            case .notFound:
                return "onboarding.city.error.notfound"
            case .network:
                return "onboarding.city.error.network"
            case .denied:
                return "onboarding.city.error.denied"
            case .unknown:
                return "onboarding.city.error.generic"
            }
        }
    }

    private let geocode: @Sendable (String) async throws -> [GeocodedPlace]

    init(geocode: @escaping @Sendable (String) async throws -> [GeocodedPlace] = CityLookupService.systemGeocode) {
        self.geocode = geocode
    }

    func resolveCity(named input: String) async throws -> City {
        let query = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { throw LookupError.emptyInput }

        do {
            let places = try await geocode(query)
            guard let place = places.first, let latitude = place.latitude, let longitude = place.longitude else {
                throw LookupError.notFound
            }

            let name = place.locality ?? place.subLocality ?? place.name ?? query
            let country = place.country ?? "Unknown"
            let timeZoneId = place.timeZoneId ?? TimeZone.current.identifier

            return City(
                name: name,
                country: country,
                latitude: latitude,
                longitude: longitude,
                timeZoneId: timeZoneId
            )
        } catch let error as LookupError {
            throw error
        } catch let error as CLError {
            switch error.code {
            case .network:
                throw LookupError.network
            case .denied:
                throw LookupError.denied
            case .geocodeFoundNoResult, .geocodeFoundPartialResult:
                throw LookupError.notFound
            default:
                throw LookupError.unknown
            }
        } catch {
            throw LookupError.unknown
        }
    }

    private static func systemGeocode(_ query: String) async throws -> [GeocodedPlace] {
        let geocoder = CLGeocoder()
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(query) { placemarks, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let results = (placemarks ?? []).map {
                    GeocodedPlace(
                        name: $0.name,
                        locality: $0.locality,
                        subLocality: $0.subLocality,
                        country: $0.country,
                        latitude: $0.location?.coordinate.latitude,
                        longitude: $0.location?.coordinate.longitude,
                        timeZoneId: $0.timeZone?.identifier
                    )
                }
                continuation.resume(returning: results)
            }
        }
    }
}
