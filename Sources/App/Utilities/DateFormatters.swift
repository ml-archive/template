import Foundation

struct DateFormatters {
    // yyyy-MM-dd'T'HH:mm:ssZ
    public static var iso8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }

    // yyyy-MM-dd
    public static var date: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
