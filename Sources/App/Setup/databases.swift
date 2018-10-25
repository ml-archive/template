import FluentMySQL
import Redis
import Vapor

public func databases(config: inout DatabasesConfig) throws {
    // MARK: MySQL

    config.add(database: MySQLDatabase(config: AppConfig.mysql), as: .mysql)

    // MARK: Redis

    config.add(database: RedisDatabase.self, as: .redis)
}
