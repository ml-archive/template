import AdminPanel
import Bugsnag
import FluentMySQL
import JWTKeychain
import Leaf
import NMeta
import NodesSSO
import Paginator
import Redis
import Reset
import Sugar
import Vapor

extension AdminPanelConfig where U == AdminPanelUser {
    static func current(_ environment: Environment) throws -> AdminPanelConfig<AdminPanelUser> {
        let projectConfig = try ProjectConfig.current()
        return try .init(
            name: projectConfig.name,
            baseURL: projectConfig.url,
            views: AdminPanelViews(
                login: AdminPanelViews.Login(index: ViewPath.AdminPanel.Login.index),
                dashboard: AdminPanelViews.Dashboard(index: ViewPath.AdminPanel.Dashboard.index)
            ),
            sidebarMenuPathGenerator: { role in
                guard let role = role else { return "" }
                switch role {
                case .superAdmin: return ViewPath.AdminPanel.Layout.Sidebars.superAdmin
                case .admin: return ViewPath.AdminPanel.Layout.Sidebars.admin
                case .user: return ViewPath.AdminPanel.Layout.Sidebars.user
                }
            },
            resetSigner: .hs256(key: assertEnv(EnvironmentKey.AdminPanel.signerKey)),
            environment: environment
        )
    }
}

extension BugsnagConfig {
    static func current(_ environment: Environment) -> BugsnagConfig {
        .init(
            apiKey: env(EnvironmentKey.Bugsnag.key, ""),
            releaseStage: environment.name
        )
    }
}

extension CORSMiddleware.Configuration {
    static var current: CORSMiddleware.Configuration {
        .init(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
            allowedHeaders: [
                .accept,
                .accessControlAllowOrigin,
                .authorization,
                .contentType,
                .origin,
                .userAgent,
                .xRequestedWith,
                HTTPHeaderName(NMetaConfig.current.headerKey)
            ]
        )
    }
}

extension JWTKeychainConfig where U == AppUser {
    static func current(container: Container) throws -> JWTKeychainConfig<AppUser> {
        try .init(
            accessTokenSigner: ExpireableJWTSigner(
                expirationPeriod: 1.hoursInSecs,
                signer: .hs256(key: assertEnv(EnvironmentKey.JWTKeychain.accessTokenSignerKey))
            ),
            refreshTokenSigner: ExpireableJWTSigner(
                expirationPeriod: 365.daysInSecs,
                signer: .hs256(key: assertEnv(EnvironmentKey.JWTKeychain.refreshTokenSignerKey))
            ),
            endpoints: .apiPrefixed
        )
    }
}

extension MySQLDatabaseConfig {
    static func current() throws -> MySQLDatabaseConfig {
        guard
            let url = env(EnvironmentKey.MySQL.url),
            let config = try? MySQLDatabaseConfig(url: url)
        else {
            let projectConfig = try ProjectConfig.current()
            return .init(
                hostname: env(EnvironmentKey.MySQL.hostname, "127.0.0.1"),
                username: env(EnvironmentKey.MySQL.username, "root"),
                password: env(EnvironmentKey.MySQL.password, ""),
                database: env(
                    EnvironmentKey.MySQL.database,
                    projectConfig.name.lowercased()
                )
            )
        }

        return config
    }
}

extension NMetaConfig {
    static var current: NMetaConfig {
        .init(
            exceptPaths: [
                // favicons
                "/apple-touch-icon-precomposed.png",
                "/apple-touch-icon.png",
                "/favicon.ico",
                "/favicons/*",

                "/AdminPanel/*",
                "/NodesSSO/*",
                "/Reset/*",
                "/admin*",
                "/api/users/reset-password/*",
                "/css/*",
                "/images/*",
                "/js/*",
                "/robots.txt"
            ]
        )
    }
}

extension NodesSSOConfig where U == AdminPanelUser {
    static func current(
        _ middlewares: [Middleware],
        environment: Environment
    ) throws -> NodesSSOConfig<AdminPanelUser> {
        let projectConfig = try ProjectConfig.current()
        return .init(
            projectURL: projectConfig.url,
            loginPath: "/admin/sso/login",
            redirectURL: env(EnvironmentKey.NodesSSO.redirectURL, ""),
            callbackPath: "/admin/sso/callback",
            salt: env(EnvironmentKey.NodesSSO.salt, ""),
            middlewares: middlewares,
            environment: environment,
            skipSSO: environment.name == "local"
        )
    }
}

extension OffsetPaginatorConfig {
    static var current: OffsetPaginatorConfig {
        .init(
            perPage: 25,
            defaultPage: 1
        )
    }
}

extension ProjectConfig {
    static func current() throws -> ProjectConfig {
        try .init(
            name: assertEnv(EnvironmentKey.Project.name),
            url: env(EnvironmentKey.Project.url, "http://localhost:8080"),
            resetPasswordEmail: .init(
                fromEmail: "no-reply@like.st",
                subject: "Reset Password"
            ),
            setPasswordEmail: .init(
                fromEmail: "no-reply@like.st",
                subject: "Set Password"
            ),
            newUserRequestEmail: .init(
                fromEmail: "no-reply@like.st",
                toEmail: "test+user@nodes.dk",
                subject: "New User Request"
            ),
            newAppUserSetPasswordSigner: ExpireableJWTSigner(
                expirationPeriod: 30.daysInSecs,
                signer: .hs256(key: assertEnv(EnvironmentKey.Reset.setPasswordSignerKey))
            )
        )
    }
}

extension RedisClientConfig {
    static var current: RedisClientConfig {
        guard
            let urlString = env(EnvironmentKey.Redis.url),
            let url = URL(string: urlString)
        else {
            var components = URLComponents()
            components.host = env(EnvironmentKey.Redis.hostname, "127.0.0.1")
            components.port = 6379
            components.scheme = "redis"
            components.path = "/" + env(EnvironmentKey.Redis.database, "0")

            if let url = components.url {
                return .init(url: url)
            } else {
                return .init()
            }
        }

        return .init(url: url)
    }
}

extension ResetConfig where U == AppUser {
    static func current(container: Container) throws -> ResetConfig<AppUser> {
        let projectConfig = try ProjectConfig.current()
        return try .init(
            name: projectConfig.name,
            baseURL: projectConfig.url,
            endpoints: .apiPrefixed,
            signer: .hs256(key: assertEnv(EnvironmentKey.Reset.signerKey)),
            responses: .current
        )
    }
}

extension ResetResponses {
    static var current: ResetResponses {
        .init(
            resetPasswordRequestForm: { req in
                try HTTPResponse(status: .notFound).encode(for: req)
            },
            resetPasswordUserNotified: { req in
                try HTTPResponse(status: .noContent).encode(for: req)
            },
            resetPasswordForm: { req, user in
                try req
                    .make(LeafRenderer.self)
                    .render(ViewPath.Reset.form)
                    .encode(for: req)
            },
            resetPasswordSuccess: { req, user in
                try req
                    .make(LeafRenderer.self)
                    .render(ViewPath.Reset.success)
                    .encode(for: req)
            }
        )
    }
}
