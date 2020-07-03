import Vapor

struct AppUserCreateCommand: Command {
    struct Signature: CommandSignature {
        @Argument(
            name: "name",
            help: "User name"
        )
        var name: String

        @Argument(
            name: "email",
            help: "Unique email address"
        )
        var email: String

        @Option(
            name: "password",
            short: "p",
            help: "Password must have at least eight characters"
        )
        var password: String?
    }

    static let defaultPassword = "FooBar123"

    var help: String {
        """
        Creates a new app user with the provided name, email and password. If no password is \
        provided, the default password "\(Self.defaultPassword)" is used.
        """
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let password = signature.password ?? Self.defaultPassword
        let hashedPassword = try context.application.password.hash(password)

        let user = AppUser(
            name: signature.name,
            email: signature.email,
            hashedPassword: hashedPassword
        )

        return try context
            .application
            .repositories
            .appUser(context.application.db)
            .save(user)
            .map { user in
                context.console.info("Created new app user with:")
                context.console.info(" - name: \(user.name)")
                context.console.info(" - email: \(user.email)")
                context.console.info(" - password: \(password)")
            }
            .wait()
    }
}
