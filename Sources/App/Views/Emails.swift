import HypertextLiteral

extension HTMLViewRenderer {
    func passwordResetEmail(name: String, resetLink: String) -> HTML {
        """
        <html>
            <body>
                <p>Hi \(name)</p>
                <a href="\(resetLink)">Reset your password</a>
            </body>
        </html>
        """
    }

    func welcomeEmail(name: String, resetLink: String) -> HTML {
        """
        <html>
            <body>
                <p>Hi \(name)</p>
                <a href="\(resetLink)">Set your password</a>
            </body>
        </html>
        """
    }
}
