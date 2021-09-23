import Core
import JWT
import Keychain
import Vapor

public struct AppUserJWTPayload: KeychainPayload {
    public let exp: ExpirationClaim
    public let sub: SubjectClaim

    public init(expirationDate: Date, user: AppUser) throws {
        self.exp = .init(value: expirationDate)
        try self.sub = .init(value: user.requireID().description)
    }

    public func findUser(request: Request) -> EventLoopFuture<AppUser> {
        request.repositories.appUser.findAppUser(UUID(uuidString: sub.value))
            .unwrap(or: CoreError.entityNotFound(ofType: AppUser.self, withID: self.sub.value))
    }

    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
