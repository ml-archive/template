import Fluent

extension AppUser {
    struct Create: Migration {
        private let entity = AppUser()

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database
                .schema(schema)
                .id()
                .field(.email, .string, .required)
                .field(.name, .string, .required)
                .field(.hashedPassword, .string, .required)
                .field(.shouldResetPassword, .bool, .required)
                .field(.createdAt, .datetime)
                .field(.updatedAt, .datetime)
                .unique(on: .id, .email)
                .create()
                .flatMap {
                    database.createIndex(for: .email, onTable: schema)
                }
                .flatMap {
                    database.createIndex(for: .name, onTable: schema)
                }
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
