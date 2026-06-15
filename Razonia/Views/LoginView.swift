import SwiftUI
import SwiftData

// MARK: - Liquid Glass Design System

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            // Base deep space gradient
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.00, blue: 0.10),
                    Color(red: 0.08, green: 0.00, blue: 0.18),
                    Color(red: 0.12, green: 0.00, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Soft radial glow blobs (liquid feel)
            RadialGradient(
                colors: [Color(red: 0.55, green: 0.0, blue: 0.9).opacity(0.35), .clear],
                center: .init(x: 0.15, y: 0.25),
                startRadius: 0, endRadius: 400
            )
            RadialGradient(
                colors: [Color(red: 0.9, green: 0.05, blue: 0.2).opacity(0.25), .clear],
                center: .init(x: 0.85, y: 0.75),
                startRadius: 0, endRadius: 350
            )
            RadialGradient(
                colors: [Color(red: 0.0, green: 0.4, blue: 0.8).opacity(0.15), .clear],
                center: .init(x: 0.7, y: 0.1),
                startRadius: 0, endRadius: 280
            )
        }
        .ignoresSafeArea()
    }
}

struct LiquidCard<Content: View>: View {
    var content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        content()
            .padding(28)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.08),
                                        Color(red: 0.7, green: 0.1, blue: 1.0).opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
            .shadow(color: .black.opacity(0.45), radius: 40, x: 0, y: 16)
            .shadow(color: Color(red: 0.55, green: 0.0, blue: 0.9).opacity(0.2), radius: 60, x: 0, y: 0)
    }
}

struct LiquidTextField: View {
    var placeholder: String
    @Binding var text: String
    var icono: String
    var esContrasena: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.7, green: 0.1, blue: 1.0), Color(red: 0.9, green: 0.1, blue: 0.3)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 20)

            if esContrasena {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                }
        }
    }
}

struct LiquidButton: View {
    var titulo: String
    var icono: String? = nil
    var colores: [Color] = [Color(red: 0.75, green: 0.05, blue: 0.9), Color(red: 0.5, green: 0.0, blue: 0.7)]
    var accion: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: accion) {
            HStack(spacing: 8) {
                if let ic = icono {
                    Image(systemName: ic)
                }
                Text(titulo)
                    .font(.system(size: 15, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(colors: colores, startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(hovering ? 0.15 : 0.06))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                    }
            }
            .foregroundColor(.white)
            .scaleEffect(hovering ? 1.015 : 1.0)
            .shadow(color: colores.first?.opacity(0.5) ?? .clear, radius: hovering ? 20 : 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: hovering)
        .onHover { hovering = $0 }
    }
}

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var ctx

    @State private var usuario = ""
    @State private var contrasena = ""
    @State private var error: String?
    @State private var mostrarRegistro = false
    @State private var aparecer = false

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.7, green: 0.05, blue: 1.0).opacity(0.4), Color(red: 0.9, green: 0.05, blue: 0.2).opacity(0.3)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                            .blur(radius: 20)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.9, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.15, blue: 0.4)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                    }

                    Text("RAZONIA")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 0.7, green: 0.1, blue: 1.0).opacity(0.6), radius: 20)

                    Text("Entrena tu mente. Domina la razón.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                        .kerning(1.5)
                }
                .padding(.bottom, 48)
                .opacity(aparecer ? 1 : 0)
                .offset(y: aparecer ? 0 : -20)

                // Card
                LiquidCard {
                    VStack(spacing: 20) {
                        if let error {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.callout)
                                    .foregroundColor(.orange.opacity(0.9))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        LiquidTextField(placeholder: "Usuario", text: $usuario, icono: "person.fill")
                        LiquidTextField(placeholder: "Contraseña", text: $contrasena, icono: "lock.fill", esContrasena: true)

                        LiquidButton(titulo: "Iniciar Sesión", icono: "arrow.right.circle.fill", accion: intentarLogin)

                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                            Text("o")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                        }

                        Button { mostrarRegistro = true } label: {
                            HStack(spacing: 4) {
                                Text("¿No tienes cuenta?")
                                    .foregroundColor(.white.opacity(0.45))
                                Text("Regístrate")
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(red: 0.8, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: 420)
                .opacity(aparecer ? 1 : 0)
                .offset(y: aparecer ? 0 : 20)

                // Credits
                Text("Universidad Mesoamericana • RAZONIA 2026")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.top, 28)
                    .opacity(aparecer ? 1 : 0)

                Spacer()
            }
            .padding(.horizontal, 60)
        }
        .onSubmit { intentarLogin() }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                aparecer = true
            }
        }
        .sheet(isPresented: $mostrarRegistro) {
            RegistroView()
                .environmentObject(auth)
        }
    }

    private func intentarLogin() {
        error = nil
        if let msg = auth.login(usuario: usuario, contrasena: contrasena, contexto: ctx) {
            withAnimation(.spring(response: 0.3)) { error = msg }
        }
    }
}
