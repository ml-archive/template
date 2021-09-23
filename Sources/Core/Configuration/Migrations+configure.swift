import FluentKit
import Vapor

extension Migrations {
    public func configure() {
        add(
            AppUser.Create()
        )
    }
}
