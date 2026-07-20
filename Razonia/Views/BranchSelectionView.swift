import SwiftUI

struct BranchSelectionView: View {
    @Binding var ramaSeleccionada: RamaID?

    let columnas = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.05, green: 0.0, blue: 0.15)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Fondo decorativo
            GeometryReader { geo in
                Circle()
                    .fill(Color(red: 0.4, green: 0.0, blue: 0.8).opacity(0.12))
                    .frame(width: geo.size.width * 0.7)
                    .blur(radius: 80)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
                Circle()
                    .fill(Color(red: 0.0, green: 0.5, blue: 0.9).opacity(0.08))
                    .frame(width: geo.size.width * 0.6)
                    .blur(radius: 80)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )

                        Text("RAZONIA")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.3, blue: 1.0), Color(red: 1.0, green: 0.2, blue: 0.5)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .kerning(4)

                        Text("Elige tu rama de entrenamiento")
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .padding(.top, 56)
                    .padding(.bottom, 8)

                    // Grid de ramas
                    LazyVGrid(columns: columnas, spacing: 16) {
                        ForEach(RamaID.allCases) { rama in
                            ramaCard(rama)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
    }

    private func ramaCard(_ rama: RamaID) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                ramaSeleccionada = rama
            }
        } label: {
            VStack(spacing: 10) {
                Text(rama.emoji)
                    .font(.system(size: 36))

                Text(rama.nombre)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: rama.gradiente.map { $0.opacity(0.15) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: rama.gradiente.map { $0.opacity(0.6) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
            }
            .shadow(color: rama.gradiente[0].opacity(0.25), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
