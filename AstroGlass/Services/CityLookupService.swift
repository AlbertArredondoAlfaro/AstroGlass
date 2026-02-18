import Foundation
import MapKit

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
        } catch let error as MKError {
            switch error.code {
            case .placemarkNotFound:
                throw LookupError.notFound
            case .serverFailure:
                throw LookupError.network
            case .directionsNotFound:
                throw LookupError.notFound
            default:
                throw LookupError.unknown
            }
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost:
                throw LookupError.network
            default:
                throw LookupError.unknown
            }
        } catch {
            throw LookupError.unknown
        }
    }

    private static func systemGeocode(_ query: String) async throws -> [GeocodedPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address]

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.map { item in
            let address = item.address
            let representations = item.addressRepresentations
            let location = item.location
            return GeocodedPlace(
                name: item.name ?? address?.shortAddress ?? address?.fullAddress,
                locality: representations?.cityName,
                subLocality: representations?.cityWithContext,
                country: representations?.regionName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timeZoneId: TimeZone.current.identifier
            )
        }
    }
}
