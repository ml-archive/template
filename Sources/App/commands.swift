import Vapor

func commands(_ app: Application) {
    app.commands.use(AppUserCreateCommand(), as: "appuser:create")
}
