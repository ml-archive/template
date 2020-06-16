import JWT
import Keychain
import Vapor

struct AppUserJWTPayload: KeychainPayload {
    let exp: ExpirationClaim
    let sub: SubjectClaim

    init(expirationDate: Date, user: AppUser) throws {
        self.exp = .init(value: expirationDate)
        try self.sub = .init(value: user.requireID().description)
    }

    func findUser(request: Request) -> EventLoopFuture<AppUser> {
        request.repositories.appUser.find(UUID(uuidString: sub.value))
            .unwrap(or: AppError.entityNotFound(ofType: AppUser.self, withID: self.sub.value))
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
