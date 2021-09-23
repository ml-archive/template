import Core
import Fluent
import Vapor

extension Application {
    public struct Repositories {
        fileprivate struct Key: StorageKey {
            typealias Value = Repositories
        }

        public var appUser: (Database) -> AppUserRepository
    }

    public var repositories: Repositories {
        get {
            storage[Repositories.Key.self, orSetDefault: Repositories(
                appUser: { db in DatabaseRepository(db: db) }
            )]
        }
        set {
            storage[Repositories.Key.self] = newValue
        }
    }
}
