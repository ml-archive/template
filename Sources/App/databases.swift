import FluentPostgresDriver
import Vapor

func databases(_ app: Application) throws {
    try app.databases.use(.postgres(url: Environment.postgreSQLURL), as: .psql)
}
