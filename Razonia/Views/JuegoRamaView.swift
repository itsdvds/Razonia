import SwiftUI
import SwiftData

struct JuegoRamaView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    var usuario: UserProgress
    var nivelInicial: Int
    var rama: RamaID

    @StateObject private var vm: GameViewModelRama

    init(usuario: UserProgress, nivelInicial: Int, rama: RamaID) {
        self.usuario = usuario
        self.nivelInicial = nivelInicial
        self.rama = rama
        _vm = StateObject(wrappedValue: GameViewModelRama(progress: usuario, rama: rama))
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(spacing: 0) {
                barraJuego
                Divider().overlay(rama.gradiente[0].opacity(0.3))
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
                        .frame(maxWidth: 700).frame(maxWidth: .infinity)
                    }
                } else {
                    Spacer()
                    ProgressView().controlSize(.large).tint(rama.gradiente[0])
                    Spacer()
                }
            }
            if vm.mostrarModalCorrecto { modalCorrectoOverlay }
            if vm.mostrarModalDerrota  { modalDerrotaOverlay  }
            if vm.mostrarRamaCompletada { ramaCompletadaOverlay }
        }
        .onAppear { vm.actualizar(progress: usuario); vm.iniciarNivel(nivelInicial) }
        .onChange(of: usuario.vidas) { vm.actualizar(progress: usuario) }
        .onChange(of: usuario.xp)    { vm.actualizar(progress: usuario) }
    }

    // MARK: - Barra
    private var barraJuego: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.06)))
            }.buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text(rama.emoji + " " + rama.nombre)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                Text("Nivel \(vm.nivelEnJuego)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            HStack(spacing: 10) {
                Label("\(usuario.xp) XP", systemImage: "bolt.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red:1,green:0.75,blue:0))
                Label("x\(usuario.vidas)", systemImage: "heart.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red:1,green:0.2,blue:0.3))
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
    }

    // MARK: - Pregunta
    private var tarjetaPregunta: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(vm.preguntaActual?.p ?? "")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(LinearGradient(colors: rama.gradiente.map{$0.opacity(0.4)}, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                }
        }
    }

    // MARK: - Pista
    @ViewBuilder
    private var pistaSection: some View {
        if let pista = vm.pistaMostrada {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill").foregroundColor(rama.gradiente[0])
                Text(pista).font(.system(size: 14)).foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { RoundedRectangle(cornerRadius: 12).fill(rama.gradiente[0].opacity(0.08)).overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(rama.gradiente[0].opacity(0.25), lineWidth: 1)) }
        }
    }

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
            Text(vm.feedback)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(vm.feedbackEsError ? Color(red:1,green:0.3,blue:0.3) : Color(red:0.3,green:0.9,blue:0.4))
                .padding(14)
                .frame(maxWidth: .infinity)
                .background { RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)) }
        }
    }

    // MARK: - Campo respuesta
    private var campRespuesta: some View {
        VStack(spacing: 14) {
            TextField("Tu respuesta...", text: $vm.respuestaTexto)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(16)
                .background { RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.06)).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.12), lineWidth: 1)) }
                .onSubmit { vm.verificarRespuesta() }

            HStack(spacing: 12) {
                Button { vm.pistaMostrada = vm.preguntaActual?.pista } label: {
                    Label("Pista", systemImage: "lightbulb.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(rama.gradiente[0])
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background { RoundedRectangle(cornerRadius: 10).fill(rama.gradiente[0].opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(rama.gradiente[0].opacity(0.3), lineWidth: 1)) }
                }.buttonStyle(.plain)

                Spacer()

                Button { vm.verificarRespuesta() } label: {
                    Text("Verificar")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                        }
                }.buttonStyle(.plain)
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
            withAnimation(.spring(response: 0.3)) {
                _ = vm.usarBooster(tipo)
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
            VStack(spacing: 20) {
                Text("✅").font(.system(size: 52))
                Text("¡Correcto!").font(.system(size: 26, weight: .black)).foregroundColor(.white)
                if let exp = vm.explicacionMostrada {
                    Text(exp).font(.system(size: 14)).foregroundColor(.white.opacity(0.7)).multilineTextAlignment(.center).lineSpacing(4)
                }
                Button {
                    withAnimation(.spring(response: 0.4)) { vm.continuar() }
                } label: {
                    Text("Continuar")
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 32).padding(.vertical, 14)
                        .background { RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing)) }
                }.buttonStyle(.plain)
            }
            .padding(32)
            .background { RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial).overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(rama.gradiente[0].opacity(0.4), lineWidth: 1)) }
            .frame(maxWidth: 420).padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    // MARK: - Modal Derrota
    private var modalDerrotaOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("💔").font(.system(size: 52))
                Text("Sin vidas").font(.system(size: 26, weight: .black)).foregroundColor(.white)
                Text("Perdiste todas tus vidas. Retrocediste 3 niveles.").font(.system(size: 14)).foregroundColor(.white.opacity(0.6)).multilineTextAlignment(.center)
                Button { vm.mostrarModalDerrota = false; dismiss() } label: {
                    Text("Volver al mapa")
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background { RoundedRectangle(cornerRadius: 12).fill(Color(red:0.8,green:0.0,blue:0.1)) }
                }.buttonStyle(.plain)
            }
            .padding(32)
            .background { RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial) }
            .frame(maxWidth: 380).padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    // MARK: - Rama Completada
    private var ramaCompletadaOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 20) {
                Text(rama.emoji)
                    .font(.system(size: 68))
                    .shadow(color: rama.gradiente[0].opacity(0.6), radius: 26)

                Text("¡\(rama.nombre.uppercased()) COMPLETADA!")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                    .multilineTextAlignment(.center)

                Text("Dominaste los 25 niveles de \(rama.nombre). Ganaste la insignia de esta rama y nuevas recompensas para seguir entrenando.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.68))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                VStack(spacing: 6) {
                    Text("INSIGNIA DESBLOQUEADA")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.35))
                        .kerning(1.2)
                    Text("\(rama.emoji) Maestro de \(rama.nombre)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                }
                .padding(14)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(rama.gradiente[0].opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(rama.gradiente[0].opacity(0.35), lineWidth: 1))
                }

                if usuario.insigniaRazonia {
                    Text("🏆 Razonia Completado: ya completaste todas las ramas.")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.2))
                        .multilineTextAlignment(.center)
                }

                Button {
                    vm.mostrarRamaCompletada = false
                    dismiss()
                } label: {
                    Text("Volver al mapa")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(rama.gradiente[0].opacity(0.45), lineWidth: 1))
            }
            .frame(maxWidth: 460)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}
