import Foundation

extension Date {
    var toBirthTime: BirthTime {
        let c = Calendar.current.dateComponents([.hour, .minute], from: self)
        return BirthTime(hour: c.hour ?? 12, minute: c.minute ?? 0)
    }
}
