import SwiftUI
import SwiftData

// 1. Estructura auxiliar para manejar el nivel de forma segura en la hoja dinámica
struct NivelIdentificable: Identifiable {
    let id: Int // El número real del nivel
}

struct MapaView: View {
    @EnvironmentObject var auth: AuthViewModel
    var usuario: UserProgress
    var onVolverRamas: (() -> Void)?

    // CORRECCIÓN: Se reemplazan 'nivelSeleccionado' y 'mostrarJuego' por un solo estado seguro
    @State private var nivelActivo: NivelIdentificable?
    
    @State private var mostrarPerfil = false
    @State private var mostrarTienda = false
    @State private var modoExtremo = false
    
    // CORRECCIÓN: Controla la visibilidad del overlay localmente en la sesión
    @State private var cerrarBienvenidaManualmente = false

    // CORRECCIÓN: Propiedad computada que evalúa dinámicamente si el usuario cumple las condiciones de ser nuevo
    private var mostrarBienvenida: Bool {
        // Si el usuario tiene 0 XP y está en el nivel inicial (1), califica como nuevo usuario
        let esUsuarioNuevo = (usuario.xp == 0 && usuario.nivelMaximo == 1)
        return esUsuarioNuevo && !cerrarBienvenidaManualmente
    }

    let colPrincipal = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)
    let colExtremo   = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                barraTop

                Divider()
                    .overlay(
                        LinearGradient(
                            colors: [Color(red: 0.7, green: 0.1, blue: 1.0).opacity(0.4), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                // Insignias
                insigniasRow

                ScrollView {
                    VStack(spacing: 32) {
                        if !modoExtremo {
                            zonaSection("⚡ ZONA RAZONIA", rango: 1...90, esExtrema: false)
                            botonZonaExtrema
                        } else {
                            botonVolverNormal
                            zonaSection("🔥 ZONA EXTREMA", rango: 91...120, esExtrema: true)
                        }
                    }
                    .padding(28)
                }
            }

            // Bienvenida overlay (Se muestra condicionalmente bajo las nuevas reglas)
            if mostrarBienvenida {
                bienvenidaOverlay
            }
        }
        // CORRECCIÓN: Despliegue seguro usando .sheet(item:). Evita estados nulos al renderizar.
        .sheet(item: $nivelActivo) { nivel in
            JuegoView(usuario: usuario, nivelInicial: nivel.id)
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

    // MARK: - Top Bar
    private var barraTop: some View {
        HStack(spacing: 16) {
            if let onVolverRamas {
                topBtn(icono: "chevron.left", etiqueta: "Ramas", accion: onVolverRamas)
            }

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

            // Center: XP + Vidas
            HStack(spacing: 12) {
                statPill(icono: "bolt.fill", valor: "\(usuario.xp) XP",
                         colores: [Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 0.9, green: 0.5, blue: 0.0)])
                statPill(icono: "heart.fill", valor: "x\(usuario.vidas)",
                         colores: [Color(red: 1.0, green: 0.2, blue: 0.3), Color(red: 0.8, green: 0.0, blue: 0.1)])
            }

            Spacer()

            // Right: buttons
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

    // MARK: - Insignias Row
    @ViewBuilder
    private var insigniasRow: some View {
        if usuario.insigniaRazonia || usuario.insigniaLogica || usuario.insigniaHackerPensamiento {
            HStack(spacing: 12) {
                if usuario.insigniaRazonia {
                    insigniaPill("🏆", "Razonia Completado",
                                 colores: [Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 0.8, green: 0.5, blue: 0.0)])
                }
                if usuario.insigniaLogica {
                    insigniaPill("🧩", "Razonamiento Lógico",
                                 colores: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)])
                }
                if usuario.insigniaHackerPensamiento {
                    insigniaPill("🎖️", "Hacker del Pensamiento Lógico",
                                 colores: [Color(red: 0.8, green: 0.0, blue: 0.15), Color(red: 1.0, green: 0.1, blue: 0.3)])
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 10)
        }
    }

    private func insigniaPill(_ emoji: String, _ texto: String, colores: [Color]) -> some View {
        HStack(spacing: 8) {
            Text(emoji)
            Text(texto)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(LinearGradient(colors: colores, startPoint: .leading, endPoint: .trailing))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill((colores.first ?? .yellow).opacity(0.08))
                .overlay(Capsule().strokeBorder((colores.first ?? .yellow).opacity(0.35), lineWidth: 1))
        }
    }

    // MARK: - Zona Section
    private func zonaSection(_ titulo: String, rango: ClosedRange<Int>, esExtrema: Bool) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(titulo)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(
                        esExtrema
                        ? LinearGradient(colors: [Color(red: 0.9, green: 0.05, blue: 0.2), Color(red: 0.5, green: 0.0, blue: 0.05)], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color(red: 0.7, green: 0.2, blue: 1.0), Color(red: 0.9, green: 0.1, blue: 0.4)], startPoint: .leading, endPoint: .trailing)
                    )
                    .kerning(1)
                Spacer()
                Text("\(rango.lowerBound)–\(rango.upperBound)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.35))
            }

            LazyVGrid(columns: esExtrema ? colExtremo : colPrincipal, spacing: 10) {
                ForEach(rango, id: \.self) { n in
                    nivelBtn(n, esExtrema: esExtrema)
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            esExtrema
                            ? Color(red: 0.9, green: 0.05, blue: 0.2).opacity(0.3)
                            : Color(red: 0.7, green: 0.1, blue: 1.0).opacity(0.2),
                            lineWidth: 1
                        )
                }
        }
    }

    // MARK: - Botón del Nivel
    private func nivelBtn(_ n: Int, esExtrema: Bool) -> some View {
        let unlocked = n <= usuario.nivelMaximo
        let completado   = n < usuario.nivelMaximo

        return Button {
            guard unlocked else { return }
            nivelActivo = NivelIdentificable(id: n)
        } label: {
            VStack(spacing: 3) {
                Text(esExtrema ? "EX\(n - 90)" : "\(n)")
                    .font(.system(size: esExtrema ? 10 : 13, weight: .bold))
                if completado {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .foregroundColor(unlocked ? .white : .white.opacity(0.2))
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(fondoNivel(n, desbloqueado: unlocked, completado: completado, esExtrema: esExtrema))
                    .overlay {
                        if !unlocked {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.4))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(borderNivel(n, desbloqueado: unlocked, completado: completado, esExtrema: esExtrema), lineWidth: 1)
                    }
            }
            .opacity(unlocked ? 1.0 : 0.5)
            .overlay(alignment: .topTrailing) {
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(4)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }

    private func fondoNivel(_ n: Int, desbloqueado: Bool, completado: Bool, esExtrema: Bool) -> AnyShapeStyle {
        if !desbloqueado {
            return AnyShapeStyle(Color.white.opacity(0.04))
        }
        if esExtrema {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.55, green: 0.0, blue: 0.08), Color(red: 0.35, green: 0.0, blue: 0.05)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        if n >= 61 && n <= 90 {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.75, green: 0.55, blue: 0.0), Color(red: 0.45, green: 0.3, blue: 0.0)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        if n >= 31 && n <= 60 {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.55, green: 0.55, blue: 0.55), Color(red: 0.3, green: 0.3, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        if completado {
            return AnyShapeStyle(LinearGradient(
                colors: [Color(red: 0.3, green: 0.0, blue: 0.5).opacity(0.6), Color(red: 0.2, green: 0.0, blue: 0.35).opacity(0.6)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        return AnyShapeStyle(Color.white.opacity(0.07))
    }

    private func borderNivel(_ n: Int, desbloqueado: Bool, completado: Bool, esExtrema: Bool) -> AnyShapeStyle {
        if !desbloqueado {
            return AnyShapeStyle(Color.white.opacity(0.06))
        }
        if esExtrema {
            return AnyShapeStyle(Color(red: 0.9, green: 0.05, blue: 0.2).opacity(0.5))
        }
        if n >= 61 && n <= 90 {
            return AnyShapeStyle(Color(red: 1.0, green: 0.85, blue: 0.3).opacity(0.7))
        }
        if n >= 31 && n <= 60 {
            return AnyShapeStyle(Color(white: 0.85).opacity(0.5))
        }
        if completado {
            return AnyShapeStyle(Color(red: 0.7, green: 0.2, blue: 1.0).opacity(0.4))
        }
        return AnyShapeStyle(Color(red: 0.7, green: 0.2, blue: 1.0).opacity(0.25))
    }

    private var botonZonaExtrema: some View {
        Button {
            guard usuario.nivelMaximo > 90 || usuario.insigniaRazonia else { return }
            withAnimation(.spring(response: 0.4)) { modoExtremo = true }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: usuario.nivelMaximo > 90 ? "flame.fill" : "lock.fill")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("ZONA EXTREMA")
                        .font(.system(size: 14, weight: .black))
                        .kerning(1)
                    Text(usuario.nivelMaximo > 90 ? "Niveles 91–120 desbloqueados" : "Completa los 90 niveles principales")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .foregroundColor(usuario.nivelMaximo > 90 ? .white : .white.opacity(0.35))
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        usuario.nivelMaximo > 90
                        ? LinearGradient(colors: [Color(red: 0.5, green: 0.0, blue: 0.08), Color(red: 0.25, green: 0.0, blue: 0.04)], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.04), Color.white.opacity(0.02)], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                usuario.nivelMaximo > 90 ? Color(red: 0.9, green: 0.05, blue: 0.2).opacity(0.45) : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(usuario.nivelMaximo <= 90 && !usuario.insigniaRazonia)
    }

    private var botonVolverNormal: some View {
        Button {
            withAnimation(.spring(response: 0.4)) { modoExtremo = false }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                Text("Volver a Zona Razonia")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Bienvenida Overlay (CORREGIDO)
    private var bienvenidaOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .blur(radius: 0.5)

            LiquidCard {
                VStack(spacing: 20) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )

                    Text("BIENVENIDO A RAZONIA")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)

                    Text("Plataforma interactiva diseñada para potenciar el desarrollo del pensamiento lógico a través de ejercicios dinámicos y progresivos. Los usuarios pueden resolver retos, poner a prueba sus habilidades y mejorar su razonamiento.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Divider().overlay(Color.white.opacity(0.1))

                    VStack(spacing: 4) {
                        Text("Desarrollado por:")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                        Text("Percy Santizo • Fredy Geancarlo")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Text("Universidad Mesoamericana")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.4))
                            .padding(.top, 4)
                    }

                    // CORRECCIÓN: Al presionar cambia el estado local.
                    // No afectará a otros usuarios nuevos que entren después en ceros.
                    LiquidButton(titulo: "¡Comenzar!", icono: "arrow.right.circle.fill") {
                        withAnimation(.spring(response: 0.4)) {
                            cerrarBienvenidaManualmente = true
                        }
                    }
                }
            }
            .frame(maxWidth: 480)
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }
}
