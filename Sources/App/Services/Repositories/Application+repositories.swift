import Fluent
import Vapor

extension Application {
    struct Repositories {
        fileprivate struct Key: StorageKey {
            typealias Value = Repositories
        }

        var appUser: (Database) -> AppUserRepository = DatabaseRepository.init
    }

    var repositories: Repositories {
        get {
            storage[Repositories.Key.self, orSetDefault: Repositories()]
        }
        set {
            storage[Repositories.Key.self] = newValue
        }
    }
}
