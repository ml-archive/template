import JWT
import Keychain
import Vapor

struct AppUserJWTPayload: KeychainPayload {
    let exp: ExpirationClaim
    let sub: SubjectClaim

    init(expirationDate: Date, user: AppUser) throws {
        self.exp = .init(value: expirationDate)
        self.sub = .init(value: try user.requireID())
    }

    func findUser(request: Request) -> EventLoopFuture<AppUser> {
        request.repositories.appUser.find(sub.value)
            .unwrap(or: AppError.entityNotFound(ofType: AppUser.self, withID: self.sub.value))
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
