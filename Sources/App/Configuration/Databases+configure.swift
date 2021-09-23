import FluentPostgresDriver
import Vapor

extension Databases {
    func configure() {
        // Remove any percent-encoding from password
        guard
            var configuration = PostgresConfiguration(url: Environment.PostgreSQL.url),
            let decodedPassword = configuration.password?.removingPercentEncoding
        else {
            fatalError("Invalid PostgreSQL URL: \(Environment.PostgreSQL.url)")
        }
        configuration.password = decodedPassword

        use(.postgres(configuration: configuration), as: .psql)
    }
}
