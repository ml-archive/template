import Vapor

extension Application {
    public func configure() throws {
        bugsnag.configure()
        commands.configure()
        mailgun.configure()
        middleware.configure(self)
        migrations.configure()
        nMeta.configure()
        keychain.configure(self)
        databases.configure()
        try routes.configure()
        views.configure()
    }
}
