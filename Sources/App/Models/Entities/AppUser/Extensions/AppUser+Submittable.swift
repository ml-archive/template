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

        public static func makeFields(for instance: Submission?) throws -> [Field] {
            return try [
                Field(
                    keyPath: \.name,
                    instance: instance,
                    label: "Name",
                    validators: [.count(5...191)]
                ),
                Field(
                    keyPath: \.password,
                    instance: instance,
                    label: "Password",
                    validators: [.count(8...)]
                ),
                Field(
                    keyPath: \.passwordAgain,
                    instance: instance,
                    label: "Password again",
                    validators: [.count(8...)]
                )
            ]
        }
    }
    
    static func makeAdditionalFields(
        for submission: Submission?,
        given existing: AppUser?
    ) throws -> [Field] {
        return try [Field(
            keyPath: \.email,
            instance: submission,
            label: "Email address",
            asyncValidators: [{ req, context in
                validateThat(
                    only: existing,
                    has: existing?.email,
                    for: \.email,
                    on: req
                )
            }]
        )]
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
