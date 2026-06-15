import SwiftUI
import SwiftData

struct RegistroView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var carne = ""
    @State private var correo = ""
    @State private var nombre = ""
    @State private var usuario = ""
    @State private var contrasena = ""
    @State private var confirmar = ""
    @State private var error: String?
    @State private var exito = false
    @State private var aparecer = false

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(10)
                                .background {
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(Circle().strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
                                }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        VStack(spacing: 3) {
                            Text("Crear Cuenta")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("Solo para estudiantes UMES")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }

                        Spacer()
                        Color.clear.frame(width: 36)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 28)

                    // Info banner
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                        Text("El carné y correo solo se usan para verificar que seas estudiante de la UMES y no se almacenan.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 0.1, green: 0.3, blue: 0.6).opacity(0.25))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(red: 0.4, green: 0.7, blue: 1.0).opacity(0.25), lineWidth: 1))
                    }
                    .padding(.horizontal, 28)

                    // Form card
                    LiquidCard {
                        VStack(spacing: 16) {
                            if let error {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                                    Text(error).font(.callout).foregroundColor(.orange.opacity(0.9))
                                }
                                .padding(12)
                                .background(Color.orange.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .transition(.scale.combined(with: .opacity))
                            }

                            if exito {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    Text("¡Cuenta creada! Iniciando sesión...")
                                        .font(.callout).foregroundColor(.green.opacity(0.9))
                                }
                                .padding(12)
                                .background(Color.green.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }

                            seccionLabel("VERIFICACIÓN")
                            LiquidTextField(placeholder: "Carné estudiantil", text: $carne, icono: "studentdesk")
                            LiquidTextField(placeholder: "Correo institucional", text: $correo, icono: "envelope.fill")

                            Divider().overlay(Color.white.opacity(0.08)).padding(.vertical, 4)

                            seccionLabel("DATOS DE CUENTA")
                            LiquidTextField(placeholder: "Nombre completo", text: $nombre, icono: "person.text.rectangle.fill")
                            LiquidTextField(placeholder: "Usuario", text: $usuario, icono: "at")
                            LiquidTextField(placeholder: "Contraseña (mín. 5 caracteres)", text: $contrasena, icono: "lock.fill", esContrasena: true)
                            LiquidTextField(placeholder: "Confirmar contraseña", text: $confirmar, icono: "lock.rotation", esContrasena: true)

                            LiquidButton(
                                titulo: "Crear Cuenta",
                                icono: "person.badge.plus",
                                colores: [Color(red: 0.0, green: 0.7, blue: 0.5), Color(red: 0.0, green: 0.5, blue: 0.8)],
                                accion: intentarRegistro
                            )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
                }
            }
            .opacity(aparecer ? 1 : 0)
            .offset(y: aparecer ? 0 : 16)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { aparecer = true }
        }
    }

    private func seccionLabel(_ texto: String) -> some View {
        HStack {
            Text(texto)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1.5)
            Spacer()
        }
    }

    private func intentarRegistro() {
            error = nil
            
            // 1. Limpiar espacios en blanco al inicio o final
            let carneLimpio = carne.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 2. Expresión regular para el formato 202X0XXXX
            let patronCarne = "^202[0-9]0[0-9]{4}$"
            
            // 3. Evaluar si el carné cumple con el patrón
            if carneLimpio.range(of: patronCarne, options: .regularExpression) == nil {
                withAnimation {
                    error = "El carné no es de la UMES"
                }
                return
            }
        if let msg = auth.registrar(
            carne: carne, correo: correo, nombre: nombre,
            usuario: usuario, contrasena: contrasena, confirmar: confirmar,
            contexto: ctx
        ) {
            withAnimation { error = msg }
        } else {
            exito = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
        }
    }
}
