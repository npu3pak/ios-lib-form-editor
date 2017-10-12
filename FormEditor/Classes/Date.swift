import Foundation

enum DateFormat: String {
    case ymdhms = "yyyy-MM-dd HH:mm:ss"
    case dmyhms = "dd.MM.yyyy HH:mm:ss"
    case dmyhm = "dd.MM.yyyy HH:mm"
    case dmy = "dd.MM.yyyy"
    case literalDmy = "dd MMMM yyyy"
    case y = "yyyy"
    case hm = "HH:mm"
}

extension Date {
    func asString(_ format: DateFormat) -> String {
        return asString(format: format.rawValue)
    }
    
    func asString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func fromString(_ value: String?, format: DateFormat) -> Date? {
        guard let value = value else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.date(from: value)
    }
}
