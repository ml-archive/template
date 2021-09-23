import Core
import FluentKit
import Vapor

public protocol AppUserRepository {
    func paginateAppUsers(searchterm: String?, on request: Request) -> EventLoopFuture<Page<AppUser>>
    func deleteAppUser(_ user: AppUser) -> EventLoopFuture<Void>
    func findAppUser(_ id: AppUser.IDValue?) -> EventLoopFuture<AppUser?>
    func findAppUserByEmail(_ email: String) -> EventLoopFuture<AppUser?>
    func saveAppUser(_ user: AppUser) -> EventLoopFuture<AppUser>
}

extension DatabaseRepository: AppUserRepository {
    public func paginateAppUsers(
        searchterm: String?,
        on request: Request
    ) -> EventLoopFuture<Page<AppUser>> {
        let query = AppUser.query(on: db)
        if let searchterm = searchterm {
            query.group(.or) { query in
                query.caseInsensitiveContains(\.$email, searchterm)
                query.caseInsensitiveContains(\.$name, searchterm)
            }
        }
        return query.paginate(for: request)
    }

    public func deleteAppUser(_ user: AppUser) -> EventLoopFuture<Void> {
        user.delete(on: db)
    }

    public func findAppUser(_ id: AppUser.IDValue?) -> EventLoopFuture<AppUser?> {
        AppUser.find(id, on: db)
    }

    public func findAppUserByEmail(_ email: String) -> EventLoopFuture<AppUser?> {
        AppUser.query(on: db).filter(\.$email == email).first()
    }

    public func saveAppUser(_ user: AppUser) -> EventLoopFuture<AppUser> {
        user.save(on: db).transform(to: user)
    }
}
