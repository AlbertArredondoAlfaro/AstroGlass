import Foundation

struct Horoscope: Equatable {
    let sign: ZodiacSign
    let weekOfYear: Int
    let paragraphs: [String]
}
