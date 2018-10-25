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

internal enum AppConfig {
    // MARK: App Config

    static var app: ProjectConfig {
        return ProjectConfig(
            name: env(EnvironmentKey.Project.name, "NodesTemplate"),
            url: env(EnvironmentKey.Project.url, "http://localhost:8080"),
            resetPasswordEmail: .init(
                fromEmail: "",
                subject: ""
            ),
            setPasswordEmail: .init(
                fromEmail: "",
                subject: ""
            ),
            newUserRequestEmail: .init(
                fromEmail: "",
                toEmail: "",
                subject: ""
            ),
            newAppUserSetPasswordSigner: ExpireableJWTSigner(
                expirationPeriod: 2592000, // 30 days
                signer: .hs256(
                    key: env(
                        EnvironmentKey.Reset.setPasswordSignerKey, "secret-reset"
                    ).convertToData()
                )
            )

        )
    }

    // MARK: MySQL

    static var mysql: MySQLDatabaseConfig {
        guard
            let url = env(EnvironmentKey.MySQL.url),
            let throwableConfig = try? MySQLDatabaseConfig(url: url),
            let config = throwableConfig
        else {
            return MySQLDatabaseConfig(
                hostname: env(EnvironmentKey.MySQL.hostname, "127.0.0.1"),
                username: env(EnvironmentKey.MySQL.username, "root"),
                password: env(EnvironmentKey.MySQL.password, ""),
                database: env(EnvironmentKey.MySQL.database, AppConfig.app.name.lowercased())
            )
        }

        return config
    }

    // MARK: Redis

    static var redis: RedisClientConfig {
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

        return RedisClientConfig(url: url)
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
            name: AppConfig.app.name,
            baseURL: AppConfig.app.url,
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
            name: AppConfig.app.name,
            baseURL: AppConfig.app.url,
            endpoints: .stark,
            signer: ExpireableJWTSigner(
                expirationPeriod: 3600, // 1 hour
                signer: .hs256(
                    key: env(EnvironmentKey.Reset.signerKey, "secret-reset"
                ).convertToData())
            ),
            responses: .nodes
        )
    }

    // MARK: Nodes SSO

    static func nodesSSO(_ middlewares: [Middleware], environment: Environment) -> NodesSSOConfig {
        return NodesSSOConfig(
            projectURL: AppConfig.app.url,
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

    // MARK: Bugsnag

    static func bugsnag(_ environment: Environment) -> BugsnagConfig {
        return BugsnagConfig(
            apiKey: env(EnvironmentKey.Bugsnag.key, ""),
            releaseStage: environment.name
        )
    }
}

extension ResetResponses {
    public static var nodes: ResetResponses {
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
                    .render(ViewPath.Reset.form)
                    .encode(for: req)
            },
            resetPasswordSuccess: { req, user in
                return try req
                    .make(LeafRenderer.self)
                    .render(ViewPath.Reset.success)
                    .encode(for: req)
            }
        )
    }
}
