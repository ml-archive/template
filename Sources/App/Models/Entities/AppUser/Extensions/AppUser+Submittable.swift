import AdminPanel
import Fluent
import Submissions
import Sugar
import Validation

extension AppUser: Submittable {
    public struct Submission: SubmissionType {
        let email: String?
        let name: String?
        let password: String?
        let passwordAgain: String?

        public init(_ user: AppUser?) {
            email = user?.email
            name = user?.name
            password = nil
            passwordAgain = nil
        }

        public func fieldEntries() throws -> [FieldEntry<AppUser>] {
            return try [
                makeFieldEntry(
                    keyPath: \Submission.email,
                    label: "Email address",
                    asyncValidators: [{ email, context, appUser, req in
                        validateThat(
                            only: appUser,
                            has: email,
                            for: \AppUser.email,
                            on: req
                        )
                        }]
                ),
                makeFieldEntry(
                    keyPath: \Submission.name,
                    label: "Name",
                    validators: [.count(5...191)]
                ),
                makeFieldEntry(
                    keyPath: \Submission.password,
                    label: "Password",
                    validators: [.count(8...)]
                ),
                makeFieldEntry(
                    keyPath: \Submission.passwordAgain,
                    label: "Password again",
                    validators: [.count(8...)]
                )
            ]
        }
    }

    public struct Create: Decodable {
        let email: String
        let name: String
        let password: String
    }

    public convenience init(_ create: Create) throws {
        try self.init(
            email: create.email,
            name: create.name,
            password: AppUser.hashPassword(create.password)
        )
    }

    public func update(_ submission: Submission) throws {
        if let email = submission.email, !email.isEmpty {
            self.email = email
        }

        if let name = submission.name, !name.isEmpty{
            self.name = name
        }

        if let password = submission.password, !password.isEmpty {
            self.password = try AppUser.hashPassword(password)
        }
    }
}
