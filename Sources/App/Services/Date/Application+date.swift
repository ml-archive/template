import Vapor

extension Application {
    struct Date {
        fileprivate struct Key: StorageKey {
            typealias Value = Date
        }
        var current: () -> Foundation.Date = Foundation.Date.init
    }

    var date: Date {
        get {
            storage[Date.Key.self, orSetDefault: Date()]
        }
        set {
            storage[Date.Key.self] = newValue
        }
    }
}
