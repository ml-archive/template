import AdminPanel
import Sugar
import Vapor

func commands(config: inout CommandConfig) {
    config.useFluentCommands()
    config.use(AdminPanelProvider<AdminPanelUser>.commands(databaseIdentifier: .mysql))
}
