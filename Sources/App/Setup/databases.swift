import FluentMySQL
import Redis
import Vapor

public func databases(config: inout DatabasesConfig) throws {
    // MARK: MySQL

    var databases = DatabasesConfig()
    config.add(database: MySQLDatabase(config: Configs.mysql), as: .mysql)

    // MARK: Redis

    databases.add(database: RedisDatabase.self, as: .redis)
}
