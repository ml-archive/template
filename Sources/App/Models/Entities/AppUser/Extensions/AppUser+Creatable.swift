import Sugar

extension AppUser: Creatable {
    struct Create: Decodable {
        let email: String
        let name: String
        let password: String
    }

    convenience init(_ create: Create) throws {
        try self.init(
            email: create.email,
            name: create.name,
            password: create.password
        )
    }
}
