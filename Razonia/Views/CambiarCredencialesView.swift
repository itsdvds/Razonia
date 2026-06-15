import SwiftUI
import SwiftData

struct CambiarCredencialesView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    
    @State private var nuevoUsuario = ""
    @State private var nuevaPassword = ""
    @State private var confirmarPassword = ""
    
    @State private var mensajeError: String?
    @State private var exito = false
    
    var body: some View {
        ZStack {
            // Fondo animado y consistente con Razonia
            LiquidGlassBackground()
            
            VStack(spacing: 24) {
                // Encabezado
                VStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.8, green: 0.2, blue: 1.0), Color(red: 0.4, green: 0.1, blue: 0.8)],
                            startPoint: .top, endPoint: .bottom
                        ))
                    
                    Text("Credenciales de Administrador")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Actualiza los datos de acceso para el panel de control.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 10)
                
                // Formulario
                VStack(spacing: 16) {
                    // Campo Usuario
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nuevo Usuario Admin")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.3))
                            TextField("Ej: admin_central", text: $nuevoUsuario)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                                // Al ser macOS/iOS multiambiente, eliminamos el modificador conflictivo.
                                // Nota: En macOS los TextField estándar no auto-capitalizan el texto.
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    
                    // Campo Contraseña
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nueva Contraseña")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                        
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.white.opacity(0.3))
                            SecureField("Mínimo 5 caracteres", text: $nuevaPassword)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    
                    // Confirmar Contraseña
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirmar Nueva Contraseña")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                        
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.white.opacity(0.3))
                            SecureField("Repite la contraseña", text: $confirmarPassword)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                
                // Alertas de Error o Éxito
                if let error = mensajeError {
                    Text("⚠️ \(error)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                        .transition(.opacity)
                }
                
                if exito {
                    Text("✅ Credenciales actualizadas correctamente")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Botones de Acción
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancelar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        actualizarCredenciales()
                    } label: {
                        Text("Guardar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(
                                colors: [Color(red: 0.8, green: 0.1, blue: 0.5), Color(red: 0.5, green: 0.0, blue: 0.8)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .frame(width: 400, height: 530)
    }
    
    private func actualizarCredenciales() {
        mensajeError = nil
        
        let userTrim = nuevoUsuario.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validaciones
        guard !userTrim.isEmpty else {
            mensajeError = "El usuario no puede estar vacío."
            return
        }
        
        guard nuevaPassword.count >= 5 else {
            mensajeError = "La contraseña debe tener mínimo 5 caracteres."
            return
        }
        
        guard nuevaPassword == confirmarPassword else {
            mensajeError = "Las contraseñas no coinciden."
            return
        }
        
        // Persistencia directa con SwiftData
        let credenciales = AdminCredentials.obtener(contexto: ctx)
        credenciales.user = userTrim
        credenciales.passwordHash = PasswordHasher.hash(nuevaPassword)
        
        withAnimation {
            exito = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}
