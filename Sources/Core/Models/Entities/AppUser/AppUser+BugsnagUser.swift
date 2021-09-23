import Bugsnag

extension AppUser: BugsnagUser {
    public var bugsnagID: CustomStringConvertible? { id }
}
