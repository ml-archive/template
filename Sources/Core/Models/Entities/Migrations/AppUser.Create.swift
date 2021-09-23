import FluentKit

extension AppUser {
    struct Create: Migration {
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
                .unique(on: .email)
                .create()
                .flatMap {
                    database.createIndex(for: .email, .name, onTable: schema)
                }
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
