import SwiftUI

// Extensión de seguridad para SwiftData y mapeo dinámico de colores
extension UserProgress {
    var profileIconOpt: String? {
        get { self.profileIconName }
        set { self.profileIconName = newValue }
    }
    
    var profileColorOpt: String {
        get { self.profileColorName ?? "purple" }
        set { self.profileColorName = newValue }
    }
    
    // Mapea el String guardado a un degradado de colores real para la interfaz líquida
    var resolvedGradient: LinearGradient {
        switch profileColorOpt {
        case "blue":
            return LinearGradient(colors: [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.0, green: 0.2, blue: 0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "green":
            return LinearGradient(colors: [Color(red: 0.2, green: 0.9, blue: 0.4), Color(red: 0.0, green: 0.5, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "orange":
            return LinearGradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 0.8, green: 0.2, blue: 0.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "pink":
            return LinearGradient(colors: [Color(red: 1.0, green: 0.3, blue: 0.7), Color(red: 0.7, green: 0.0, blue: 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "yellow":
            return LinearGradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.2), Color(red: 0.8, green: 0.4, blue: 0.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: // "purple"
            return LinearGradient(colors: [Color(red: 0.7, green: 0.05, blue: 1.0), Color(red: 0.4, green: 0.0, blue: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct PerfilView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    var usuario: UserProgress

    // Estado para abrir la ventana de selección de iconos y colores
    @State private var mostrarSelectorIconos = false

    // Iconos universales 100% compatibles con macOS (Soluciona el bug de las 3 opciones vacías)
    let iconosDisponibles = [
        "person.fill", "rocket.fill", "sparkles", "moon.stars.fill",
        "globe.americas.fill", "sun.max.fill", "brain.head.profile", "cpu",
        "terminal.fill", "crown.fill", "shield.fill", "gamecontroller.fill"
    ]
    
    // Paleta de colores líquidos disponibles para personalizar el perfil
    let coloresDisponibles = ["purple", "blue", "green", "orange", "pink", "yellow"]

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Header optimizado sin espacios muertos exagerados
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Mi Perfil")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()
                    
                    // Equilibrador exacto invisible para centrar el título nítidamente
                    Color.clear.frame(width: 34, height: 34)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 16) { // Compactado el espaciado vertical
                        
                        // Avatar editable con selector de Iconos y Colores
                        VStack(spacing: 14) {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(usuario.resolvedGradient) // Aplica el gradiente elegido
                                    .frame(width: 84, height: 84)
                                    .shadow(color: Color.black.opacity(0.3), radius: 8)

                                // Renderiza el icono seleccionado o la inicial por defecto
                                if let iconName = usuario.profileIconOpt, !iconName.isEmpty {
                                    Image(systemName: iconName)
                                        .font(.system(size: 34))
                                        .foregroundColor(.white)
                                        .frame(width: 84, height: 84)
                                } else {
                                    Text(String(usuario.nombre.prefix(1)).uppercased())
                                        .font(.system(size: 36, weight: .black))
                                        .foregroundColor(.white)
                                }

                                // Botón flotante para editar avatar (Usa paleta de pintura)
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        mostrarSelectorIconos.toggle()
                                    }
                                } label: {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                                        .padding(4)
                                        .background(Circle().fill(Color.black.opacity(0.8)))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Ventana colapsable interactiva para cambiar el ícono y color en el acto
                            if mostrarSelectorIconos {
                                VStack(spacing: 14) {
                                    
                                    // SUBSECCIÓN 1: Selección de Color
                                    VStack(spacing: 8) {
                                        Text("COLOR DE FONDO")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white.opacity(0.4))
                                            .kerning(1.2)
                                        
                                        HStack(spacing: 12) {
                                            ForEach(coloresDisponibles, id: \.self) { colorName in
                                                Button {
                                                    usuario.profileColorOpt = colorName
                                                } label: {
                                                    Circle()
                                                        .fill(getColorSample(colorName))
                                                        .frame(width: 24, height: 24)
                                                        .overlay(
                                                            Circle()
                                                                .strokeBorder(.white, lineWidth: usuario.profileColorOpt == colorName ? 2 : 0)
                                                        )
                                                        .shadow(radius: 2)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    
                                    Divider().overlay(Color.white.opacity(0.08))
                                    
                                    // SUBSECCIÓN 2: Selección de Icono
                                    VStack(spacing: 8) {
                                        Text("ICONO DE AVATAR")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white.opacity(0.4))
                                            .kerning(1.2)
                                        
                                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                                            ForEach(iconosDisponibles, id: \.self) { icon in
                                                Button {
                                                    usuario.profileIconOpt = icon
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                        mostrarSelectorIconos = false
                                                    }
                                                } label: {
                                                    Image(systemName: icon)
                                                        .font(.system(size: 18))
                                                        .foregroundColor(usuario.profileIconOpt == icon ? .white : .white.opacity(0.6))
                                                        .frame(width: 44, height: 44)
                                                        .background(usuario.profileIconOpt == icon ? Color.white.opacity(0.12) : Color.white.opacity(0.04))
                                                        .clipShape(Circle())
                                                        .overlay(
                                                            Circle()
                                                                .strokeBorder(usuario.profileIconOpt == icon ? Color.white.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                                                        )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 6)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.04)))
                                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.06), lineWidth: 1))
                                .transition(.asymmetric(insertion: .push(from: .top).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
                            }

                            VStack(spacing: 2) {
                                Text(usuario.nombre)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)

                                Text("@\(usuario.username)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.45))
                            }

                            Text(usuario.rango)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 4)
                                .background {
                                    Capsule()
                                        .fill(Color(red: 0.7, green: 0.05, blue: 1.0).opacity(0.2))
                                        .overlay(Capsule().strokeBorder(Color(red: 0.7, green: 0.05, blue: 1.0).opacity(0.4), lineWidth: 1))
                                }
                                .foregroundStyle(LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                        }
                        .padding(.vertical, 4)

                        // Métricas compactas sin empujar la vista verticalmente
                        LiquidCard {
                            VStack(spacing: 0) {
                                statRow(icono: "bolt.fill", titulo: "XP Total", valor: "\(usuario.xp)",
                                        colores: [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 0.8, green: 0.5, blue: 0.0)])
                                Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, -20)
                                statRow(icono: "star.fill", titulo: "Nivel Máximo", valor: "\(usuario.nivelMaximo) / 120",
                                        colores: [Color(red: 0.7, green: 0.3, blue: 1.0), Color(red: 0.5, green: 0.0, blue: 0.8)])
                                Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, -20)
                                statRow(icono: "heart.fill", titulo: "Vidas", valor: "\(usuario.vidas)",
                                        colores: [Color(red: 1.0, green: 0.2, blue: 0.3), Color(red: 0.8, green: 0.0, blue: 0.1)])
                            }
                        }

                        // Boosters
                        LiquidCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("BOOSTERS EN INVENTARIO")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white.opacity(0.3))
                                    .kerning(1.5)

                                HStack(spacing: 0) {
                                    ForEach(BoosterTipo.allCases) { tipo in
                                        miniBooster(tipo)
                                        if tipo != BoosterTipo.allCases.last {
                                            Divider().overlay(Color.white.opacity(0.06))
                                        }
                                    }
                                }
                            }
                        }

                        // Insignias
                        if usuario.insigniaRazonia
                            || usuario.insigniaHackerPensamiento
                            || RamaID.allCases.contains(where: { usuario.tieneInsigniaRama($0) }) {
                            LiquidCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("INSIGNIAS GANADAS")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white.opacity(0.3))
                                        .kerning(1.5)

                                    if usuario.insigniaRazonia {
                                        insigniaRow("🏆", "Razonia Completado", "Completaste todas las ramas de entrenamiento",
                                                   colores: [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 0.8, green: 0.5, blue: 0.0)])
                                    }
                                    ForEach(RamaID.allCases) { rama in
                                        if usuario.tieneInsigniaRama(rama) {
                                            insigniaRow(rama.emoji, "Maestro de \(rama.nombre)", "Completaste la rama de \(rama.nombre)",
                                                       colores: rama.gradiente)
                                        }
                                    }
                                    if usuario.insigniaHackerPensamiento {
                                        insigniaRow("🎖️", "Hacker del Pensamiento Lógico", "Conquistaste la Zona Extrema completa",
                                                   colores: [Color(red: 0.9, green: 0.05, blue: 0.2), Color(red: 0.6, green: 0.0, blue: 0.08)])
                                    }
                                }
                            }
                        }

                        // Cerrar sesión
                        LiquidButton(
                            titulo: "Cerrar Sesión",
                            icono: "rectangle.portrait.and.arrow.right",
                            colores: [Color(red: 0.7, green: 0.05, blue: 0.1), Color(red: 0.5, green: 0.0, blue: 0.05)]
                        ) {
                            auth.logout()
                            dismiss()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 520)
    }

    // Auxiliar para las muestras de color del panel
    private func getColorSample(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "yellow": return .yellow
        default: return .purple
        }
    }

    private func statRow(icono: String, titulo: String, valor: String, colores: [Color]) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .font(.system(size: 14))
                .foregroundStyle(LinearGradient(colors: colores, startPoint: .top, endPoint: .bottom))
                .frame(width: 20)

            Text(titulo)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            Text(valor)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
    }

    private func miniBooster(_ tipo: BoosterTipo) -> some View {
        VStack(spacing: 4) {
            Image(systemName: tipo.icono)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
            Text("x\(usuario.cantidad(de: tipo))")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
            Text(tipo.nombre)
                .font(.system(size: 8))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    private func insigniaRow(_ emoji: String, _ titulo: String, _ desc: String, colores: [Color]) -> some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: colores, startPoint: .leading, endPoint: .trailing))
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.45))
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill((colores.first ?? .purple).opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder((colores.first ?? .purple).opacity(0.2), lineWidth: 1))
        }
    }
}
