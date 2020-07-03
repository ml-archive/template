import Vapor

extension AppUser: SessionAuthenticatable {
    var sessionID: String { id?.description ?? "" }
}
