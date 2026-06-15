import Foundation
import SwiftData

@Model
final class AdminCredentials {
    var user: String
    var passwordHash: String

    init(user: String, passwordHash: String) {
        self.user = user
        self.passwordHash = passwordHash
    }

    /// Returns the existing AdminCredentials or creates a default one.
    static func obtener(contexto: ModelContext) -> AdminCredentials {
        let descriptor = FetchDescriptor<AdminCredentials>()
        if let existing = (try? contexto.fetch(descriptor))?.first {
            return existing
        }
        let nuevo = AdminCredentials(
            user: "UMES",
            passwordHash: PasswordHasher.hash("RAZONIA2026")
        )
        contexto.insert(nuevo)
        return nuevo
    }
}
