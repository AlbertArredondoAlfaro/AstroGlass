import Foundation

struct BirthTime: Codable, Equatable {
    var hour: Int
    var minute: Int
}

struct UserProfile: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var birthDate: Date
    var birthTime: BirthTime?
    var cityName: String
    var latitude: Double
    var longitude: Double
    var timeZoneId: String
    var sunSign: ZodiacSign
    var risingSign: ZodiacSign

    var hasExactTime: Bool { birthTime != nil }
}
