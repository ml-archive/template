import AdminPanel
import Fluent
import Submissions
import Sugar
import Validation

extension AppUser: Submittable {
    struct Submission: Decodable & FieldsRepresentable & Reflectable {
        let email: String?
        let name: String?
        let oldPassword: String?
        let password: String?
        let passwordAgain: String?

        static func makeFields(for instance: Submission?) throws -> [Field] {
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
                    validators: [.count(8...), .strongPassword()]
                ),
                Field(
                    keyPath: \.passwordAgain,
                    instance: instance,
                    label: "Password again",
                    validators: [Validator("") {
                        guard $0 == instance?.password else {
                            throw BasicValidationError("Passwords do not match")
                        }
                    }]
                )
            ]
        }
    }

    func makeSubmission() -> AppUser.Submission? {
        return Submission(
            email: email,
            name: name,
            oldPassword: nil,
            password: nil,
            passwordAgain: nil
        )
    }

    static func makeAdditionalFields(
        for submission: Submission?,
        given existing: AppUser?
    ) throws -> [Field] {
        return try [Field(
            keyPath: \.email,
            instance: submission,
            label: "Email address",
            validators: [.email],
            asyncValidators: [{ req, context in
                validateThat(
                    only: existing,
                    has: submission?.email,
                    for: \.email,
                    on: req
                )
            }]
        )]
    }
}
