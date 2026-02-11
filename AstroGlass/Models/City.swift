import Foundation

struct City: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let timeZoneId: String

    init(id: UUID = UUID(), name: String, country: String, latitude: Double, longitude: Double, timeZoneId: String) {
        self.id = id
        self.name = name
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.timeZoneId = timeZoneId
    }

    enum CodingKeys: String, CodingKey {
        case name, country, latitude, longitude, timeZoneId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        name = try container.decode(String.self, forKey: .name)
        country = try container.decode(String.self, forKey: .country)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        timeZoneId = try container.decode(String.self, forKey: .timeZoneId)
    }
}
