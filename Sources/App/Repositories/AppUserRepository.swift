import Fluent
import Vapor

protocol AppUserRepository {
    func all(searchterm: String?, on request: Request) -> EventLoopFuture<Page<AppUser>>
    func delete(_ user: AppUser) -> EventLoopFuture<Void>
    func find(_ id: AppUser.IDValue?) -> EventLoopFuture<AppUser?>
    func save(_ user: AppUser) -> EventLoopFuture<AppUser>
}

extension DatabaseRepository: AppUserRepository {
    func all(
        searchterm: String?,
        on request: Request
    ) -> EventLoopFuture<Page<AppUser>> {
        let query = AppUser.query(on: db)
        if let searchterm = searchterm {
            query.filter(\.$email ~~ searchterm)
        }
        return query.paginate(for: request)
    }

    func delete(_ user: AppUser) -> EventLoopFuture<Void> {
        user.delete(on: db)
    }

    func find(_ id: AppUser.IDValue?) -> EventLoopFuture<AppUser?> {
        AppUser.find(id, on: db)
    }

    func save(_ user: AppUser) -> EventLoopFuture<AppUser> {
        user.save(on: db).transform(to: user)
    }
}
