import AdminPanel
import Sugar
import Vapor

public func commands(config: inout CommandConfig) {
    config.useFluentCommands()
    config.use(
        SeederCommand<AdminPanelUser>(databaseIdentifier: .mysql),
        as: "adminpanel:user-seeder"
    )
}
