import Vapor

struct AppUserCreateCommand: Command {
    struct Signature: CommandSignature {
        @Argument(
            name: "userID",
            help: "Provide a unique userID"
        )
        var userID: UUID

        @Option(
            name: "password",
            short: "p",
            help: "Password must have at least eight characters"
        )
        var password: String?
    }

    var help: String {
        "Creates a new respondent with the provided userID and password."
    }

    func run(using context: CommandContext, signature: Signature) throws {
        let userID = signature.userID
        let password = signature.password ?? "FooBar123"
        let hashedPassword = try context.application.password.hash(password)

        let user = AppUser(id: userID, hashedPassword: hashedPassword)

        return try context
            .application
            .repositories
            .appUser(context.application.db)
            .save(user)
            .map { _ in
                context.console.info("Created new app user with:", newLine: true)
                context.console.info("userID: \(String(describing: userID))", newLine: true)
                context.console.info("password: \(password)", newLine: true)
            }
            .wait()
    }
}
