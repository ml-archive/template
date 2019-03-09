import FluentMySQL
import Redis
import Vapor

func databases(config: inout DatabasesConfig) throws {
    // MARK: MySQL

    config.add(database: MySQLDatabase(config: .current), as: .mysql)

    // MARK: Redis

    config.add(database: RedisDatabase.self, as: .redis)
}
