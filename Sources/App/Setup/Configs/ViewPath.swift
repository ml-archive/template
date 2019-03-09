enum ViewPath {
    private static let prefix = "App"

    enum Reset {
        private static let reset = prefix + "/Reset"
        static let form = reset + "/Password/reset-password-form"
        static let success = reset + "/Password/reset-password-success"
        static let resetPasswordEmail = reset + "/request-reset-password-email"
    }

    enum AdminPanel {
        private static let adminPanel = prefix + "/AdminPanel"

        enum Layout {
            private static let layout = adminPanel + "/Layout"

            enum Sidebars {
                private static let sidebar = layout + "/Partials/Sidebars"
                static let user = sidebar + "/user"
                static let admin = sidebar + "/admin"
                static let superAdmin = sidebar + "/superadmin"
            }
        }

        enum Login {
            private static let login = adminPanel + "/Login"
            static let index = login + "/index"
        }

        enum Dashboard {
            private static let dashboard = adminPanel + "/Dashboard"
            static let index = dashboard + "/index"
        }
    }
}
