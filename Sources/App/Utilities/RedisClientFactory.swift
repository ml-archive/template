import Redis
import Vapor

final internal class RedisClientFactory: Service {
    func make(on container: Container) throws -> Future<RedisClient> {
        let config: RedisClientConfig = try container.make()
        return RedisClient.connect(
            hostname: config.hostname,
            port: config.port,
            password: config.password,
            on: container,
            onError: { error in
                // TODO: Bugsnag
                print("Redis error: \(error)")
            }
        )
    }
}
