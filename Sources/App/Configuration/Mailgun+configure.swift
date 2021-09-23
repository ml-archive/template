import Vapor

extension Application.Mailgun {
    func configure() {
        configuration = .init(apiKey: Environment.Mailgun.apiKey)
        defaultDomain = .init(Environment.Mailgun.defaultDomain, Environment.Mailgun.region)
    }
}
