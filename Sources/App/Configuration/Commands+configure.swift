import User
import Vapor

extension Commands {
    mutating func configure() {
        use(AppUserCreateCommand(), as: "appuser:create")
    }
}
