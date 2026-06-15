import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var ctx
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        Group {
            if auth.esAdmin {
                AdminView()
                    .environmentObject(auth)
            } else if let usuario = auth.usuarioActual {
                MapaView(usuario: usuario)
                    .environmentObject(auth)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: auth.usuarioActual?.username)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: auth.esAdmin)
    }
}
