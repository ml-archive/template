import AdminPanel
import FluentMySQL
import JWTKeychain
import Leaf
import NMeta
import NodesSSO
import Redis
import Reset
import Sugar
import Vapor
import Paginator

internal enum Configs {
    // MARK: App Config

    static let appName = "NodesTemplate"
    static var app: AppConfig {
        return AppConfig()
    }

    // MARK: MySQL

    static var mysql: MySQLDatabaseConfig {
        return MySQLDatabaseConfig(
            hostname: env(EnvironmentKey.MySQL.hostname, "127.0.0.1"),
            username: env(EnvironmentKey.MySQL.username, "root"),
            password: env(EnvironmentKey.MySQL.password, ""),
            database: env(EnvironmentKey.MySQL.database, Configs.appName.lowercased())
        )
    }

    // MARK: Redis

    static var redis: RedisClientConfig {
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

    // MARK: N-Meta

    static var nMeta: NMetaConfig {
        return NMetaConfig(
            exceptPaths: [
                "/js/*",
                "/css/*",
                "/images/*",
                "/favicons/*",
                "/admin/*",
                "/api/users/reset-password/*"
            ]
        )
    }

    // MARK: JWT Keychain

    static var jwtKeychain: JWTKeychainConfig {
        return JWTKeychainConfig(
            accessTokenSigner: ExpireableJWTSigner(
                expirationPeriod: 3600, // 1 hour
                signer: .hs256(
                    key: env(EnvironmentKey.JWTKeychain.accessTokenSignerKey, "secret-access"
                        ).convertToData())
            ),
            refreshTokenSigner: ExpireableJWTSigner(
                expirationPeriod: 3600 * 24 * 365, // 1 year
                signer: .hs256(
                    key: env(EnvironmentKey.JWTKeychain.refreshTokenSignerKey, "secret-refresh")
                        .convertToData())
            ),
            endpoints: .apiPrefixed
        )
    }

    // MARK: Admin Panel

    static func adminPanel(_ environment: Environment) -> AdminPanelConfig<AdminPanelUser> {
        return AdminPanelConfig(
            name: env(EnvironmentKey.Project.name, Configs.appName),
            baseURL: env(EnvironmentKey.Project.url, "http://localhost:8080"),
            views: AdminPanelViews(
                login: AdminPanelViews.Login(index: AppViews.AdminPanel.Login.index),
                dashboard: AdminPanelViews.Dashboard(index: AppViews.AdminPanel.Dashboard.index)
            ),
            sidebarMenuPathGenerator: { role in
                guard let role = role else { return "" }
                switch role {
                case .superAdmin: return AppViews.AdminPanel.Layout.Sidebars.superAdmin
                case .admin: return AppViews.AdminPanel.Layout.Sidebars.admin
                case .user: return AppViews.AdminPanel.Layout.Sidebars.user
                }
            },
            newUserSetPasswordSigner: ExpireableJWTSigner(
                expirationPeriod: 2592000, // 30 days
                signer: .hs256(
                    key: env(EnvironmentKey.AdminPanel.setPasswordSignerKey, "secret-reset"
                ).convertToData())
            ),
            environment: environment
        )
    }

    // MARK: Reset
    static var reset: ResetConfig<AppUser> {
        return ResetConfig(
            name: env(EnvironmentKey.Project.name, Configs.appName),
            baseURL: env(EnvironmentKey.Project.url, "http://localhost:8080"),
            endpoints: .stark,
            signer: ExpireableJWTSigner(
                expirationPeriod: 3600, // 1 hour
                signer: .hs256(
                    key: env(EnvironmentKey.Reset.signerKey, "secret-reset"
                ).convertToData())
            ),
            responses: .stark
        )
    }

    // MARK: Nodes SSO

    static func nodesSSO(_ middlewares: [Middleware], environment: Environment) -> NodesSSOConfig {
        return NodesSSOConfig(
            projectURL: env(EnvironmentKey.NodesSSO.url, "http://localhost:8080"),
            loginPath: "/admin/sso/login",
            redirectURL: env(EnvironmentKey.NodesSSO.redirectURL, ""),
            callbackPath: "/admin/sso/callback",
            salt: env(EnvironmentKey.NodesSSO.salt, ""),
            middlewares: middlewares,
            environment: environment,
            skipSSO: environment.name == "local"
        )
    }

    // MARK: Paginator

    static var paginator: OffsetPaginatorConfig {
        return  OffsetPaginatorConfig(
            perPage: 25,
            defaultPage: 1
        )
    }
}

extension ResetResponses {
    public static var stark: ResetResponses {
        return .init(
            resetPasswordRequestForm: { req in
                return try HTTPResponse(status: .notFound).encode(for: req)
            },
            resetPasswordEmailSent: { req in
                return try HTTPResponse(status: .noContent).encode(for: req)
            },
            resetPasswordForm: { req, user in
                return try req
                    .make(LeafRenderer.self)
                    .render(AppViews.Reset.form)
                    .encode(for: req)
            },
            resetPasswordSuccess: { req, user in
                return try req
                    .make(LeafRenderer.self)
                    .render(AppViews.Reset.success)
                    .encode(for: req)
            }
        )
    }
}
