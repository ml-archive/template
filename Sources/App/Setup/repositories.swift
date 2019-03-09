import Vapor

func setUpRepositories(services: inout Services, config: inout Config) {
    // See https://docs.vapor.codes/3.0/extras/style-guide/#architecture for more information
    // on how to use repositories.
    // services.register(MySQLUserRepository.self)
    // preferDatabaseRepositories(config: &config)
}

private func preferDatabaseRepositories(config: inout Config) {
    // config.prefer(MySQLUserRepository.self, for: UserRepository.self)
}
