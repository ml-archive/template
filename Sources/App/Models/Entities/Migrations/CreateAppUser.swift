import Fluent

struct CreateAppUser: Migration {
    private let entity = AppUser()

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(AppUser.schema)
            .field(entity.$id.key, .uuid, .identifier(auto: false))
            .field(entity.$email.key, .string, .required)
            .field(entity.$hashedPassword.key, .string, .required)
            .field(entity.$createdAt.$timestamp.key, .datetime)
            .field(entity.$updatedAt.$timestamp.key, .datetime)
            .unique(on: entity.$id.key, entity.$email.key)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(AppUser.schema).delete()
    }
}
