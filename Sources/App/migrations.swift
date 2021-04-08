import Vapor

func migrations(_ app: Application) {
    app.migrations.add(AppUser.Create())
}
