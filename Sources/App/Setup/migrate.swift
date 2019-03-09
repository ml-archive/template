import AdminPanel
import FluentMySQL
import Vapor

func migrate(migrations: inout MigrationConfig) throws {
    // MARK: Preparations
    migrations.add(model: AppUser.self, database: .mysql)
    migrations.add(model: AdminPanelUser.self, database: .mysql)

    // MARK: Migrations
    // Add your migrations like this:
    // migrations.add(migration: AppUser.AddForeignKeyToAddressId.self, database: .mysql)
}
