import Fluent
import Vapor

protocol AppUserRepository {
    func paginateAppUsers(searchterm: String?, on request: Request) -> EventLoopFuture<Page<AppUser>>
    func deleteAppUser(_ user: AppUser) -> EventLoopFuture<Void>
    func findAppUser(_ id: AppUser.IDValue?) -> EventLoopFuture<AppUser?>
    func findAppUserByEmail(_ email: String) -> EventLoopFuture<AppUser?>
    func saveAppUser(_ user: AppUser) -> EventLoopFuture<AppUser>
}

extension DatabaseRepository: AppUserRepository {
    func paginateAppUsers(
        searchterm: String?,
        on request: Request
    ) -> EventLoopFuture<Page<AppUser>> {
        let query = AppUser.query(on: db)
        if let searchterm = searchterm {
            query.filter(\.$email ~~ searchterm)
        }
        return query.paginate(for: request)
    }

    func deleteAppUser(_ user: AppUser) -> EventLoopFuture<Void> {
        user.delete(on: db)
    }

    func findAppUser(_ id: AppUser.IDValue?) -> EventLoopFuture<AppUser?> {
        AppUser.find(id, on: db)
    }

    func findAppUserByEmail(_ email: String) -> EventLoopFuture<AppUser?> {
        AppUser.query(on: db).filter(\.$email == email).first()
    }

    func saveAppUser(_ user: AppUser) -> EventLoopFuture<AppUser> {
        user.save(on: db).transform(to: user)
    }
}
