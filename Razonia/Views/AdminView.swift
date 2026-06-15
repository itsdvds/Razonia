import SwiftUI
import SwiftData

struct AdminView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.modelContext) private var ctx
    @Query(sort: \UserProgress.username) private var usuarios: [UserProgress]

    @State private var busqueda = ""
    @State private var seleccionado: UserProgress?
    @State private var mostrarCambiarAdmin = false
    @State private var confirmEliminar: UserProgress?

    // Estados para la edición de credenciales del usuario seleccionado
    @State private var editNombre = ""
    @State private var editUsername = ""
    @State private var nuevaPasswordUsuario = ""
    @State private var guardadoExitoso = false

    private var usuariosFiltrados: [UserProgress] {
        busqueda.isEmpty ? usuarios : usuarios.filter {
            $0.username.localizedCaseInsensitiveContains(busqueda) ||
            $0.nombre.localizedCaseInsensitiveContains(busqueda)
        }
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                barraTop

                Divider()
                    .overlay(Color(red: 0.9, green: 0.05, blue: 0.2).opacity(0.4))

                HStack(spacing: 0) {
                    listaUsuarios
                        .frame(width: 280)

                    Divider().overlay(Color.white.opacity(0.07))

                    if let u = seleccionado {
                        detalleUsuario(u)
                    } else {
                        placeholderDetalle
                    }
                }
            }
        }
        .sheet(isPresented: $mostrarCambiarAdmin) {
            CambiarCredencialesView()
                .environmentObject(auth)
        }
        .alert("Eliminar usuario", isPresented: Binding(
            get: { confirmEliminar != nil },
            set: { if !$0 { confirmEliminar = nil } }
        )) {
            Button("Cancelar", role: .cancel) { confirmEliminar = nil }
            Button("Eliminar", role: .destructive) {
                if let u = confirmEliminar {
                    ctx.delete(u)
                    if seleccionado === u { seleccionado = nil }
                    confirmEliminar = nil
                }
            }
        } message: {
            Text("¿Eliminar a \(confirmEliminar?.nombre ?? "")? Esta acción no se puede deshacer.")
        }
        .onChange(of: seleccionado) { _, nuevoUsuario in
            if let u = nuevoUsuario {
                editNombre = u.nombre
                editUsername = u.username
                nuevaPasswordUsuario = ""
                guardadoExitoso = false
            }
        }
    }

    // MARK: - Top Bar
    private var barraTop: some View {
        HStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "shield.fill")
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 1.0, green: 0.1, blue: 0.25), Color(red: 0.7, green: 0.0, blue: 0.1)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .font(.system(size: 16))
                Text("Panel de Administración")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text("RAZONIA")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.07))
                    .clipShape(Capsule())
            }

            Spacer()

            Button { mostrarCambiarAdmin = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "key.fill")
                    Text("Credenciales Admin")
                }
                .font(.system(size: 12, weight: .semibold))
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

            Button { auth.logout() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Cerrar")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.1, blue: 0.1).opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(red: 1.0, green: 0.1, blue: 0.1).opacity(0.2), lineWidth: 1))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
    }

    // MARK: - Lista Usuarios
    private var listaUsuarios: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.35))
                    .font(.system(size: 13))
                TextField("Buscar estudiante...", text: $busqueda)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.07)), alignment: .bottom)

            HStack {
                Text("\(usuariosFiltrados.count) estudiante\(usuariosFiltrados.count == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider().overlay(Color.white.opacity(0.06))

            if usuariosFiltrados.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.15))
                    Text(busqueda.isEmpty ? "Sin estudiantes registrados" : "Sin resultados")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.3))
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(usuariosFiltrados) { u in
                            usuarioFila(u)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func usuarioFila(_ u: UserProgress) -> some View {
        let selec = seleccionado === u

        return Button { seleccionado = u } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(selec
                            ? LinearGradient(colors: [Color(red: 0.9, green: 0.05, blue: 0.2), Color(red: 0.6, green: 0.0, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.12)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 34, height: 34)
                    
                    Text(String(u.nombre.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(u.nombre)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text("@\(u.username) · Nv.\(u.nivelMaximo)")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                if selec {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.3))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selec ? Color(red: 0.8, green: 0.0, blue: 0.1).opacity(0.15) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(selec ? Color(red: 1.0, green: 0.1, blue: 0.2).opacity(0.5) : Color.clear)
                    .frame(width: 2),
                alignment: .leading
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detalle Usuario Mapeado Correctamente
    private func detalleUsuario(_ u: UserProgress) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.9, green: 0.05, blue: 0.2), Color(red: 0.6, green: 0.0, blue: 0.08)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 52, height: 52)
                        
                        Text(String(u.nombre.prefix(1)).uppercased())
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(u.nombre)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("@\(u.username) · Rango Activo")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    Spacer()

                    Button {
                        confirmEliminar = u
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "trash.fill")
                            Text("Eliminar")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(Color(red: 1.0, green: 0.1, blue: 0.1).opacity(0.08))
                                .overlay(RoundedRectangle(cornerRadius: 7).strokeBorder(Color(red: 1.0, green: 0.1, blue: 0.1).opacity(0.2), lineWidth: 1))
                        }
                    }
                    .buttonStyle(.plain)
                }

                Divider().overlay(Color.white.opacity(0.08))

                // PANEL DE EDICIÓN DE CREDENCIALES
                LiquidCard {
                    VStack(spacing: 14) {
                        seccion("DATOS DE ACCESO Y PERFIL")
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nombre Completo")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            TextField("Nombre", text: $editNombre)
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nombre de Usuario (Username)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            TextField("Username", text: $editUsername)
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                                // Modificador .textInputAutocapitalization removido aquí para compatibilidad nativa con Mac
                                .onChange(of: editUsername) { _, nuevoValor in
                                    // Asegura en tiempo de ejecución que el username sea siempre minúscula en macOS
                                    editUsername = nuevoValor.lowercased()
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Nueva Contraseña (Dejar vacío para mantener)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            SecureField("Nueva contraseña", text: $nuevaPasswordUsuario)
                                .textFieldStyle(.plain)
                                .padding(10)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        if guardadoExitoso {
                            Text("✅ Datos guardados correctamente")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.top, 4)
                        }

                        Button {
                            guard !editNombre.isEmpty, !editUsername.isEmpty else { return }
                            u.nombre = editNombre
                            u.username = editUsername
                            if !nuevaPasswordUsuario.isEmpty {
                                u.passwordHash = PasswordHasher.hash(nuevaPasswordUsuario)
                            }
                            withAnimation {
                                guardadoExitoso = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                guardadoExitoso = false
                            }
                        } label: {
                            Text("Guardar Cambios de Perfil")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(red: 0.7, green: 0.1, blue: 1.0))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // PANEL DE MÉTRICAS GENERALES
                LiquidCard {
                    VStack(spacing: 14) {
                        seccion("MÉTRICAS")
                        adminStepper("XP acumulada", val: Binding(get: { u.xp }, set: { u.xp = $0 }), min: 0, step: 10)
                        adminStepper("Nivel Máximo Alcanzado", val: Binding(get: { u.nivelMaximo }, set: { u.nivelMaximo = $0 }), min: 1, max: 120, step: 1)
                        adminStepper("Corazones / Vidas", val: Binding(get: { u.vidas }, set: { u.vidas = $0 }), min: 0, max: 10, step: 1)
                    }
                }

                // PANEL DE BOOSTERS UTILIZANDO EL AJUSTADOR COMPATIBLE (.ajustar)
                LiquidCard {
                    VStack(spacing: 14) {
                        seccion("INVENTARIO DE BOOSTERS")
                        
                        adminBoosterStepper(usuario: u, tipo: .pista, titulo: "Pistas 💡")
                        adminBoosterStepper(usuario: u, tipo: .resolver, titulo: "Resolver ⚡")
                        adminBoosterStepper(usuario: u, tipo: .vida, titulo: "Vidas +1 ❤️")
                        adminBoosterStepper(usuario: u, tipo: .doblexp, titulo: "Doble XP 🔥")
                        adminBoosterStepper(usuario: u, tipo: .saltar, titulo: "Saltar ⏭")
                    }
                }

                // CONTROL DE LOGROS E INSIGNIAS
                LiquidCard {
                    VStack(spacing: 14) {
                        seccion("INSIGNIAS Y LOGROS ESPECIALES")
                        Toggle("🏆 Modo Razonia Completado", isOn: Binding(get: { u.insigniaRazonia }, set: { u.insigniaRazonia = $0 }))
                            .foregroundColor(.white.opacity(0.75))
                            .font(.system(size: 13))
                        Toggle("🎖️ Hacker del Pensamiento Lógico", isOn: Binding(get: { u.insigniaHackerPensamiento }, set: { u.insigniaHackerPensamiento = $0 }))
                            .foregroundColor(.white.opacity(0.75))
                            .font(.system(size: 13))
                    }
                }
            }
            .padding(28)
        }
    }

    private func seccion(_ texto: String) -> some View {
        HStack {
            Text(texto)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1.5)
            Spacer()
        }
    }

    // Stepper Estándar para Propiedades Int Directas
    private func adminStepper(_ titulo: String, val: Binding<Int>, min: Int, max: Int = 99999, step: Int) -> some View {
        HStack {
            Text(titulo)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            HStack(spacing: 0) {
                Button { val.wrappedValue = Swift.max(min, val.wrappedValue - step) } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                }
                .buttonStyle(.plain)

                Text("\(val.wrappedValue)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 48)
                    .multilineTextAlignment(.center)
                    .background(Color.white.opacity(0.04))
                    .frame(height: 28)

                Button { val.wrappedValue = Swift.min(max, val.wrappedValue + step) } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
    }

    // Componente Inline especializado para modificar boosters de forma compatible y segura
    private func adminBoosterStepper(usuario: UserProgress, tipo: BoosterTipo, titulo: String) -> some View {
        HStack {
            Text(titulo)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            HStack(spacing: 0) {
                Button {
                    if usuario.cantidad(de: tipo) > 0 {
                        usuario.ajustar(tipo, por: -1)
                        ctx.processPendingChanges() // Fuerza el redibujado de SwiftData
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                }
                .buttonStyle(.plain)

                Text("\(usuario.cantidad(de: tipo))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 48)
                    .multilineTextAlignment(.center)
                    .background(Color.white.opacity(0.04))
                    .frame(height: 28)

                Button {
                    usuario.ajustar(tipo, por: 1)
                    ctx.processPendingChanges()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
        }
    }

    private var placeholderDetalle: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.08))
            Text("Selecciona un estudiante")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.2))
            Text("para ver y editar sus métricas")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
