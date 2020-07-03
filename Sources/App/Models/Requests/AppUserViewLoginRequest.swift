import Vapor

struct AppUserViewLoginRequest: Decodable {
    enum CodingKeys: String, CodingKey {
        case email
        case password
    }

    let email: String
    let password: String
}

extension AppUserViewLoginRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add(.string(CodingKeys.email.rawValue), as: String.self, is: !.empty)
        validations.add(.string(CodingKeys.password.rawValue), as: String.self, is: !.empty)
    }
}
