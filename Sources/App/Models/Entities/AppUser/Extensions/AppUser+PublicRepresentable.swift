import Sugar
import Vapor

extension AppUser: PublicRepresentable {
    struct Public: Content {
        let email: String
        let name: String
    }

    func convertToPublic(on req: Request) throws -> Future<AppUser.Public> {
        return req.future(AppUser.Public(email: email, name: name))
    }
}
