import SwiftUI
import SwiftData

struct JuegoView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    var usuario: UserProgress
    var nivelInicial: Int

    @StateObject private var vm: GameViewModel

    init(usuario: UserProgress, nivelInicial: Int) {
        self.usuario = usuario
        self.nivelInicial = nivelInicial
        _vm = StateObject(wrappedValue: GameViewModel(progress: usuario))
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                barraJuego

                Divider()
                    .overlay(Color(red: 0.7, green: 0.1, blue: 1.0).opacity(0.3))

                if vm.preguntaActual != nil {
                    ScrollView {
                        VStack(spacing: 24) {
                            tarjetaPregunta
                            pistaSection
                            dobleXPBanner
                            feedbackSection
                            campRespuesta
                            boostersPanel
                        }
                        .padding(32)
                        .frame(maxWidth: 700)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color(red: 0.7, green: 0.2, blue: 1.0))
                    Spacer()
                }
            }

            // Modals
            if vm.mostrarModalCorrecto { modalCorrectoOverlay }
            if vm.mostrarModalDerrota  { modalDerrotaOverlay  }
            if vm.mostrarVictoria      { victoriaOverlay       }
            if vm.mostrarHacker        { hackerOverlay         }
        }
        .onAppear {
            vm.actualizar(progress: usuario)
            vm.iniciarNivel(nivelInicial)
        }
    }

    // MARK: - Barra Superior
    private var barraJuego: some View {
        HStack(spacing: 16) {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Menú")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 1) {
                Text(vm.tituloNivel)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.8, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
            }

            Spacer()

            // Vidas
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(i < usuario.vidas ? Color(red: 1.0, green: 0.2, blue: 0.3) : .white.opacity(0.15))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
    }

    // MARK: - Tarjeta Pregunta
    private var tarjetaPregunta: some View {
        LiquidCard {
            VStack(spacing: 14) {
                HStack {
                    Text(vm.tituloNivel)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.1, blue: 1.0))
                    Spacer()
                }
                
                // Renderiza el enunciado de la pregunta mapeado desde la propiedad ".p"
                if let enunciado = vm.preguntaActual?.p {
                    Text(enunciado)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.vertical, 10)
                }
                
                // Despliega la explicación resuelta que viene en ".exp" al responder correctamente
                if let explicacion = vm.explicacionMostrada {
                    Text("Análisis: \(explicacion)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green.opacity(0.9))
                        .padding(10)
                        .background(Color.green.opacity(0.06))
                        .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Pista
    @ViewBuilder
    private var pistaSection: some View {
        if let pista = vm.pistaMostrada {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.0))
                Text(pista)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.6))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.3, green: 0.25, blue: 0.0).opacity(0.45))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(red: 1.0, green: 0.85, blue: 0.0).opacity(0.3), lineWidth: 1))
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    // MARK: - Doble XP Banner
    @ViewBuilder
    private var dobleXPBanner: some View {
        if vm.dobleXPActivo {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                Text("¡DOBLE XP ACTIVO! Tu próxima respuesta vale el doble.")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.7, blue: 0.3))
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.4, green: 0.2, blue: 0.0).opacity(0.4))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(red: 1.0, green: 0.5, blue: 0.0).opacity(0.4), lineWidth: 1))
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Feedback
    @ViewBuilder
    private var feedbackSection: some View {
        if !vm.feedback.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: vm.feedbackEsError ? "xmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(vm.feedbackEsError ? Color(red: 1.0, green: 0.25, blue: 0.3) : .green)
                Text(vm.feedback)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(vm.feedbackEsError ? Color(red: 1.0, green: 0.35, blue: 0.4) : .green)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Campo Respuesta
    private var campRespuesta: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "text.cursor")
                    .foregroundColor(.white.opacity(0.35))
                TextField("Escribe tu respuesta aquí...", text: $vm.respuestaTexto)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .autocorrectionDisabled()
                    .onSubmit { withAnimation { vm.verificarRespuesta() } }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color(red: 0.7, green: 0.1, blue: 1.0).opacity(0.5), Color.white.opacity(0.1)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
            }

            LiquidButton(titulo: "Responder", icono: "arrow.right.circle.fill") {
                withAnimation(.spring(response: 0.3)) { vm.verificarRespuesta() }
            }
        }
    }

    // MARK: - Boosters Panel
    private var boostersPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BOOSTERS DISPONIBLES")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1.5)

            HStack(spacing: 10) {
                ForEach(BoosterTipo.allCases) { tipo in
                    boosterBtn(tipo)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    private func boosterBtn(_ tipo: BoosterTipo) -> some View {
        let cantidad = usuario.cantidad(de: tipo)
        let disponible = cantidad > 0

        return Button {
            guard disponible else { return }
            // Solución rápida si devuelve un valor:
            withAnimation(.spring(response: 0.3)) {
                _ = vm.usarBooster(tipo) // El "_ =" le dice al compilador que ignore el valor de retorno
            }
        } label: {
            VStack(spacing: 5) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tipo.icono)
                        .font(.system(size: 20))
                        .foregroundStyle(disponible
                            ? LinearGradient(colors: colorBooster(tipo), startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [.white.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 36, height: 36)

                    Text("x\(cantidad)")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(disponible ? (colorBooster(tipo).first ?? .purple) : .gray)
                        )
                        .offset(x: 8, y: -4)
                }

                Text(tipo.nombre)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(disponible ? 0.65 : 0.25))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(disponible ? (colorBooster(tipo).first?.opacity(0.12) ?? .clear) : Color.white.opacity(0.04))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(disponible ? (colorBooster(tipo).first?.opacity(0.35) ?? .clear) : Color.white.opacity(0.07), lineWidth: 1)
                    }
            }
            .opacity(disponible ? 1.0 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!disponible)
    }

    private func colorBooster(_ tipo: BoosterTipo) -> [Color] {
        switch tipo {
        case .pista:    return [Color(red: 1.0, green: 0.85, blue: 0.0), Color(red: 0.8, green: 0.6, blue: 0.0)]
        case .resolver: return [Color(red: 0.2, green: 0.9, blue: 0.6), Color(red: 0.0, green: 0.7, blue: 0.4)]
        case .vida:     return [Color(red: 1.0, green: 0.2, blue: 0.35), Color(red: 0.8, green: 0.0, blue: 0.15)]
        case .doblexp:  return [Color(red: 1.0, green: 0.5, blue: 0.0), Color(red: 0.8, green: 0.3, blue: 0.0)]
        case .saltar:   return [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.0, green: 0.4, blue: 0.9)]
        }
    }

    // MARK: - Modal Correcto
    private var modalCorrectoOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            LiquidCard {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(red: 0.2, green: 1.0, blue: 0.5), Color(red: 0.0, green: 0.8, blue: 0.3)],
                                startPoint: .top, endPoint: .bottom
                            ))
                    }

                    Text("¡Correcto!")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.3, green: 1.0, blue: 0.5), Color(red: 0.0, green: 0.8, blue: 0.3)],
                            startPoint: .leading, endPoint: .trailing
                        ))

                    Text(vm.preguntaActual?.exp ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 10)

                    HStack(spacing: 12) {
                        Button { vm.mostrarModalCorrecto = false; dismiss() } label: {
                            Text("Menú")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.07))
                                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
                                }
                        }
                        .buttonStyle(.plain)

                        LiquidButton(titulo: "Siguiente", icono: "arrow.right.circle.fill",
                                     colores: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.0, green: 0.6, blue: 0.3)]) {
                            withAnimation { vm.continuar() }
                        }
                    }
                }
            }
            .frame(maxWidth: 440)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    // MARK: - Modal Derrota
    private var modalDerrotaOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()

            LiquidCard {
                VStack(spacing: 18) {
                    Text("💀")
                        .font(.system(size: 60))

                    Text("Sin Vidas")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 1.0, green: 0.2, blue: 0.3), Color(red: 0.7, green: 0.0, blue: 0.1)],
                            startPoint: .leading, endPoint: .trailing
                        ))

                    Text("Has retrocedido 3 niveles en tu árbol lógico. ¡Sigue intentando!")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)

                    LiquidButton(titulo: "Entendido", icono: "arrow.uturn.backward.circle.fill",
                                 colores: [Color(red: 0.8, green: 0.05, blue: 0.15), Color(red: 0.5, green: 0.0, blue: 0.05)]) {
                        vm.mostrarModalDerrota = false
                        dismiss()
                    }
                }
            }
            .frame(maxWidth: 380)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    // MARK: - Victoria Overlay (Razonia Completado)
    private var victoriaOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            LiquidCard {
                VStack(spacing: 20) {
                    Text("🏆")
                        .font(.system(size: 72))
                        .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.0).opacity(0.6), radius: 30)

                    Text("¡RAZONIA COMPLETADO!")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.0, green: 1.0, blue: 1.0), Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 1.0, green: 0.0, blue: 1.0)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .multilineTextAlignment(.center)

                    Text("¡Felicidades! Completaste los 90 niveles principales. Has desbloqueado la Zona Extrema y la insignia Razonia Completado.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 6) {
                        Text("RECOMPENSA DESBLOQUEADA")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                            .kerning(1.2)
                        Text("+500 XP • +3 Pistas • +1 Resolver • +3 Vidas • +2 Doble XP • +1 Saltar")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                            .multilineTextAlignment(.center)
                    }
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.3, green: 0.25, blue: 0.0).opacity(0.4))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color(red: 1.0, green: 0.8, blue: 0.0).opacity(0.3), lineWidth: 1))
                    }

                    LiquidButton(titulo: "Volver al Menú Principal",
                                 colores: [Color(red: 0.8, green: 0.6, blue: 0.0), Color(red: 0.6, green: 0.4, blue: 0.0)]) {
                        vm.mostrarVictoria = false
                        dismiss()
                    }
                }
            }
            .frame(maxWidth: 500)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Hacker Overlay (Zona Extrema completada)
    private var hackerOverlay: some View {
        ZStack {
            Color.black.opacity(0.88).ignoresSafeArea()

            LiquidCard {
                VStack(spacing: 20) {
                    Text("🎖️")
                        .font(.system(size: 68))
                        .shadow(color: Color(red: 1.0, green: 0.1, blue: 0.2).opacity(0.5), radius: 25)

                    Text("¡ZONA EXTREMA COMPLETADA!")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(
                            colors: [Color(red: 0.55, green: 0.0, blue: 0.08), Color(red: 1.0, green: 0.1, blue: 0.25), Color(red: 1.0, green: 0.75, blue: 0.8)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .multilineTextAlignment(.center)

                    Text("Hacker del Pensamiento Lógico")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.7))

                    Text("Superaste los niveles extra y dominaste los temas más extremos de Razonia.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)

                    LiquidButton(titulo: "Volver al Menú Principal",
                                 colores: [Color(red: 0.55, green: 0.0, blue: 0.08), Color(red: 1.0, green: 0.1, blue: 0.2)]) {
                        vm.mostrarHacker = false
                        dismiss()
                    }
                }
            }
            .frame(maxWidth: 480)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}
