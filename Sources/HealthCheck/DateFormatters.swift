// Date formatters for use in Health API
// Enables us to output iso8601 formatted dates in our API
import Foundation

struct DateFormatters {
    // yyyy-MM-dd'T'HH:mm:ssZ
    public static var iso8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }
}
