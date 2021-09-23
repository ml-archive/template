import Core
import Fluent
import Vapor

struct AppUserController {
    func me(request: Request) throws -> DataWrapper<AppUserResponse> {
        try .init(data: .init(request.auth.require()))
    }

    func create(request: Request) throws -> EventLoopFuture<Response> {
        AppUserCreateRequest
            .create(on: request)
            .flatMap(request.repositories.appUser.saveAppUser)
            .flatMapThrowing(AppUserCreateResponse.init)
            .map(DataWrapper.init)
            .encodeResponse(status: .created, for: request)
    }

    func list(request: Request) throws -> EventLoopFuture<Page<AppUserResponse>> {
        request
            .repositories
            .appUser
            .paginateAppUsers(searchterm: request.query.searchTerm, on: request)
            .flatMapThrowing { paginatedRespondents in
                try paginatedRespondents.map(AppUserResponse.init)
            }
    }

    func single(request: Request) -> EventLoopFuture<DataWrapper<AppUserResponse>> {
        request
            .repositories
            .appUser
            .findAppUser(AppUser.getParameter(on: request))
            .unwrap()
            .flatMapThrowing(AppUserCreateResponse.init)
            .map(DataWrapper.init)
    }

    func update(request: Request) throws -> EventLoopFuture<DataWrapper<AppUserUpdateResponse>> {
        AppUserUpdateRequest
            .update(on: request)
            .flatMap(request.repositories.appUser.saveAppUser)
            .flatMapThrowing(AppUserUpdateResponse.init)
            .map(DataWrapper.init)
    }

    func delete(request: Request) throws -> EventLoopFuture<HTTPStatus> {
        request
            .repositories
            .appUser
            .findAppUser(AppUser.getParameter(on: request))
            .unwrap()
            .flatMap(request.repositories.appUser.deleteAppUser)
            .transform(to: .noContent)
    }
}

extension AppUserController {
    struct Protected: RouteCollection {
        init() {
            controller = AppUserController()
        }

        let controller: AppUserController

        func boot(routes: RoutesBuilder) throws {
            routes.get("me", use: controller.me)

            routes.get("", use: controller.list)

            let singleUser = routes.grouped(AppUser.pathComponent)
            singleUser.get("", use: controller.single)
            singleUser.patch("", use: controller.update)
            singleUser.delete("", use: controller.delete)
        }
    }

    struct Unprotected: RouteCollection {
        init() {
            controller = AppUserController()
        }

        let controller: AppUserController

        func boot(routes: RoutesBuilder) throws {
            routes.post("", use: controller.create)
        }
    }
}
