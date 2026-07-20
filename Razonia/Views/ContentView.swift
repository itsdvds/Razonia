import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var ctx
    @StateObject private var auth = AuthViewModel()

    @State private var ramaSeleccionada: RamaID? = nil

    var body: some View {
        Group {
            if auth.esAdmin {
                AdminView()
                    .environmentObject(auth)
            } else if let usuario = auth.usuarioActual {
                if let rama = ramaSeleccionada {
                    if rama == .logica {
                        MapaView(usuario: usuario) {
                            withAnimation(.spring(response: 0.35)) {
                                ramaSeleccionada = nil
                            }
                        }
                            .environmentObject(auth)
                    } else {
                        MapaRamaView(usuario: usuario, rama: rama) {
                            withAnimation(.spring(response: 0.35)) {
                                ramaSeleccionada = nil
                            }
                        }
                            .environmentObject(auth)
                    }
                } else {
                    BranchSelectionView(ramaSeleccionada: $ramaSeleccionada)
                        .environmentObject(auth)
                }
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: auth.usuarioActual?.username)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: auth.esAdmin)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: ramaSeleccionada)
    }
}
