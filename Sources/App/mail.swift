import Vapor

func mail(_ app: Application) {
    app.mailgun.configuration = .init(apiKey: Environment.mailgunPassword)
    app.mailgun.defaultDomain = .init(Environment.mailgunDefaultDomain, Environment.mailgunRegion)
}
