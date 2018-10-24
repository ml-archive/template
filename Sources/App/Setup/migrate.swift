import Vapor
import FluentMySQL

public func migrate(migrations: inout MigrationConfig) throws {
    // MARK: Preparations
    migrations.add(model: AppUser.self, database: .mysql)

    // MARK: Migrations
    // Add your migrations like this:
    // migrations.add(migration: AppUser.AddForeignKeyToAddressId.self, database: .mysql)
}
