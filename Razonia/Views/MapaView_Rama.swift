import SwiftUI
import SwiftData

struct MapaRamaView: View {
    @EnvironmentObject var auth: AuthViewModel
    var usuario: UserProgress
    var rama: RamaID
    var onVolverRamas: () -> Void

    @State private var nivelActivo: NivelIdentificable?
    @State private var mostrarPerfil = false
    @State private var mostrarTienda = false
    @State private var modoExtremo = false

    let colPrincipal = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(spacing: 0) {
                barraTop
                Divider().overlay(
                    LinearGradient(colors: [rama.gradiente[0].opacity(0.4), .clear],
                                   startPoint: .leading, endPoint: .trailing)
                )
                ScrollView {
                    VStack(spacing: 32) {
                        if !modoExtremo {
                            zonaSection("⚡ ZONA \(rama.nombre.uppercased())", rango: 1...25, esExtrema: false)
                        }
                    }
                    .padding(28)
                }
            }
        }
        .sheet(item: $nivelActivo) { nivel in
            JuegoRamaView(usuario: usuario, nivelInicial: nivel.id, rama: rama)
                .environmentObject(auth)
        }
        .sheet(isPresented: $mostrarPerfil) {
            PerfilView(usuario: usuario)
                .environmentObject(auth)
        }
        .sheet(isPresented: $mostrarTienda) {
            TiendaView(usuario: usuario)
                .environmentObject(auth)
        }
    }

    private var barraTop: some View {
        HStack(spacing: 16) {
            topBtn(icono: "chevron.left", etiqueta: "Ramas", accion: onVolverRamas)

            Button {
                mostrarPerfil = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(usuario.resolvedGradient)
                            .frame(width: 38, height: 38)
                            .shadow(color: Color.black.opacity(0.2), radius: 4)

                        if let iconName = usuario.profileIconName, !iconName.isEmpty {
                            Image(systemName: iconName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        } else {
                            Text(String(usuario.nombre.prefix(1)).uppercased())
                                .font(.system(size: 17, weight: .black))
                                .foregroundColor(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(usuario.nombre)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text(usuario.rango)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.45))
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 8) {
                Text(rama.emoji).font(.title2)
                Text(rama.nombre.uppercased())
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundStyle(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                    .kerning(1)
            }

            Spacer()

            HStack(spacing: 12) {
                statPill(icono: "bolt.fill", valor: "\(usuario.xp) XP",
                         colores: [Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 0.9, green: 0.5, blue: 0.0)])
                statPill(icono: "heart.fill", valor: "x\(usuario.vidas)",
                         colores: [Color(red: 1.0, green: 0.2, blue: 0.3), Color(red: 0.8, green: 0.0, blue: 0.1)])
            }

            Spacer()

            HStack(spacing: 10) {
                topBtn(icono: "cart.fill", etiqueta: "Tienda") { mostrarTienda = true }
                topBtn(icono: "person.fill", etiqueta: "Perfil") { mostrarPerfil = true }
                topBtn(icono: "rectangle.portrait.and.arrow.right", etiqueta: "Salir", destructivo: true) { auth.logout() }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
    }

    private func statPill(icono: String, valor: String, colores: [Color]) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icono)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LinearGradient(colors: colores, startPoint: .leading, endPoint: .trailing))
            Text(valor)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background {
            Capsule()
                .fill(Color.white.opacity(0.07))
                .overlay(Capsule().strokeBorder(colores.first?.opacity(0.3) ?? .clear, lineWidth: 1))
        }
    }

    private func topBtn(icono: String, etiqueta: String, destructivo: Bool = false, accion: @escaping () -> Void) -> some View {
        Button(action: accion) {
            HStack(spacing: 6) {
                Image(systemName: icono)
                    .font(.system(size: 12))
                Text(etiqueta)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(destructivo ? Color(red: 1.0, green: 0.3, blue: 0.3) : .white.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(destructivo ? 0.04 : 0.06))
                    .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
            }
        }
        .buttonStyle(.plain)
    }

    private func zonaSection(_ titulo: String, rango: ClosedRange<Int>, esExtrema: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(titulo)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(LinearGradient(colors: rama.gradiente, startPoint: .leading, endPoint: .trailing))
                    .kerning(1)
                Spacer()
                Text("\(rango.lowerBound)–\(rango.upperBound)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.35))
            }
            LazyVGrid(columns: colPrincipal, spacing: 10) {
                ForEach(rango, id: \.self) { n in nivelBtn(n) }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(rama.gradiente[0].opacity(0.25), lineWidth: 1)
                }
        }
    }

    private func nivelBtn(_ n: Int) -> some View {
        let unlocked = n <= usuario.nivelMaximo
        let completado = n < usuario.nivelMaximo
        return Button {
            guard unlocked else { return }
            nivelActivo = NivelIdentificable(id: n)
        } label: {
            VStack(spacing: 3) {
                Text("\(n)").font(.system(size: 13, weight: .bold))
                if completado {
                    Image(systemName: "checkmark").font(.system(size: 8, weight: .bold)).foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity).frame(height: 46)
            .foregroundColor(unlocked ? .white : .white.opacity(0.2))
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(unlocked
                          ? AnyShapeStyle(LinearGradient(colors: rama.gradiente.map{$0.opacity(completado ? 0.5 : 0.25)}, startPoint: .topLeading, endPoint: .bottomTrailing))
                          : AnyShapeStyle(Color.white.opacity(0.04)))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(unlocked ? rama.gradiente[0].opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
                    }
            }
            .opacity(unlocked ? 1.0 : 0.5)
            .overlay(alignment: .topTrailing) {
                if !unlocked {
                    Image(systemName: "lock.fill").font(.system(size: 8)).foregroundColor(.white.opacity(0.3)).padding(4)
                }
            }
        }
        .buttonStyle(.plain).disabled(!unlocked)
    }
}
