import SwiftUI

struct TiendaView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    var usuario: UserProgress

    @State private var comprando: BoosterTipo?
    @State private var mensajeFlash: String?

    let tienda: [(tipo: BoosterTipo, costo: Int)] = [
        (.pista,    20),
        (.resolver, 100),
        (.vida,     35),
        (.doblexp,  50),
        (.saltar,   60)
    ]

    var body: some View {
        ZStack {
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Header ajustado y estilizado de forma ultra compacta
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(10)
                            .background { Circle().fill(Color.white.opacity(0.08)) }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Tienda de Boosters")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        HStack(spacing: 4) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                            Text("\(usuario.xp) XP disponibles")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                        }
                    }

                    Spacer()
                    Color.clear.frame(width: 34, height: 34)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if let msg = mensajeFlash {
                    Text(msg)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.opacity.combined(with: .scale))
                        .padding(.bottom, 8)
                }

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                        ForEach(tienda, id: \.tipo) { item in
                            tiendaCard(item.tipo, costo: item.costo)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func tiendaCard(_ tipo: BoosterTipo, costo: Int) -> some View {
        let puedeComprar = usuario.xp >= costo
        let colores = colorBooster(tipo)

        return Button {
            guard puedeComprar else { return }
            usuario.xp -= costo
            usuario.ajustar(tipo, por: 1)
            withAnimation {
                mensajeFlash = "✅ \(tipo.nombre) comprado"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { mensajeFlash = nil }
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill((colores.first ?? .purple).opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: tipo.icono)
                        .font(.system(size: 22))
                        .foregroundStyle(LinearGradient(colors: colores, startPoint: .top, endPoint: .bottom))
                }

                VStack(spacing: 2) {
                    Text(tipo.nombre)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text(tipo.descripcion)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 28, alignment: .top)
                }

                Divider().overlay(Color.white.opacity(0.06))

                HStack(spacing: 4) {
                    Text("x\(usuario.cantidad(de: tipo))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                    Text("\(costo) XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(puedeComprar ? Color(red: 1.0, green: 0.8, blue: 0.0) : .white.opacity(0.3))
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial.opacity(0.4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                puedeComprar ? (colores.first?.opacity(0.25) ?? .clear) : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    }
            }
            .opacity(puedeComprar ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!puedeComprar)
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
}
