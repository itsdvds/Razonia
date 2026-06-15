import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var usuarioActual: UserProgress?
    @Published var esAdmin: Bool = false

    // MARK: - Equivalent to login() (admin first, then student)
    func login(usuario: String, contrasena: String, contexto: ModelContext) -> String? {
        let userTrim = usuario.trimmingCharacters(in: .whitespacesAndNewlines)
        let passTrim = contrasena.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !userTrim.isEmpty, !passTrim.isEmpty else {
            return "Completa usuario y contraseña"
        }

        // Intenta primero como administrador
        let admin = AdminCredentials.obtener(contexto: contexto)
        if userTrim == admin.user, PasswordHasher.hash(passTrim) == admin.passwordHash {
            esAdmin = true
            usuarioActual = nil
            return nil
        }

        return loginEstudiante(usuario: userTrim, contrasena: passTrim, contexto: contexto)
    }

    private func loginEstudiante(usuario userTrim: String, contrasena passTrim: String, contexto: ModelContext) -> String? {
        let descriptor = FetchDescriptor<UserProgress>(
            predicate: #Predicate { $0.username == userTrim }
        )

        guard let perfil = (try? contexto.fetch(descriptor))?.first else {
            return "Credenciales incorrectas."
        }

        guard perfil.passwordHash == PasswordHasher.hash(passTrim) else {
            return "Credenciales incorrectas."
        }

        usuarioActual = perfil
        return nil
    }

    // MARK: - Equivalent to completarRegistro()
    /// Returns an error message, or nil on success.
    func registrar(
        carne: String,
        correo: String,
        nombre: String,
        usuario: String,
        contrasena: String,
        confirmar: String,
        contexto: ModelContext
    ) -> String? {
        let carneT = carne.trimmingCharacters(in: .whitespacesAndNewlines)
        let correoT = correo.trimmingCharacters(in: .whitespacesAndNewlines)
        let nombreT = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let userT = usuario.trimmingCharacters(in: .whitespacesAndNewlines)
        let passT = contrasena.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmT = confirmar.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !carneT.isEmpty, !correoT.isEmpty, !nombreT.isEmpty, !userT.isEmpty, !passT.isEmpty, !confirmT.isEmpty else {
            return "Completa todos los campos"
        }

        guard correoT.lowercased().hasSuffix("@umes.edu.gt") else {
            return "Debe usar un correo institucional"
        }

        guard passT == confirmT else {
            return "Las contraseñas no coinciden"
        }

        guard passT.count >= 5 else {
            return "La contraseña debe tener mínimo 5 caracteres"
        }

        let descriptor = FetchDescriptor<UserProgress>(
            predicate: #Predicate { $0.username == userT }
        )
        if let existentes = try? contexto.fetch(descriptor), !existentes.isEmpty {
            return "Ese nombre de usuario ya existe"
        }

        // Nota: como en el original, el carné y el correo solo se usan para
        // verificar que sea un correo institucional y no se almacenan.
        let nuevo = UserProgress(username: userT, nombre: nombreT, passwordHash: PasswordHasher.hash(passT))
        contexto.insert(nuevo)

        return nil
    }

    func logout() {
        usuarioActual = nil
        esAdmin = false
    }
}
