import Foundation
import Combine
import SwiftUI
import SwiftData

@MainActor
final class GameViewModelRama: ObservableObject {

    @Published var nivelEnJuego: Int = 1
    @Published var preguntaActual: PreguntaJSON?
    @Published var respuestaTexto: String = ""
    @Published var feedback: String = ""
    @Published var feedbackEsError: Bool = false
    @Published var mostrarModalCorrecto = false
    @Published var mostrarModalDerrota = false
    @Published var mostrarRamaCompletada = false
    @Published var dobleXPActivo = false
    @Published var pistaMostrada: String?
    @Published var explicacionMostrada: String?

    private var todosLosNiveles: [NivelJSON] = []
    private var progress: UserProgress
    let rama: RamaID
    private let jsonName: String

    let maxNivel = 25

    init(progress: UserProgress, rama: RamaID) {
        self.progress = progress
        self.rama = rama
        self.jsonName = rama.jsonName
        cargarNiveles()
    }

    func actualizar(progress: UserProgress) {
        self.progress = progress
    }

    private func cargarNiveles() {
        guard let url = Bundle.main.url(forResource: jsonName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([NivelJSON].self, from: data)
        else {
            feedback = "Error cargando \(jsonName).json"
            feedbackEsError = true
            return
        }
        todosLosNiveles = decoded
    }

    func iniciarNivel(_ numero: Int) {
        nivelEnJuego = numero
        respuestaTexto = ""
        feedback = ""
        feedbackEsError = false
        dobleXPActivo = false
        pistaMostrada = nil
        explicacionMostrada = nil

        if let nivelObj = todosLosNiveles.first(where: { $0.nivel == numero }),
           !nivelObj.preguntas.isEmpty {
            preguntaActual = nivelObj.preguntas.randomElement()
        } else {
            preguntaActual = nil
        }
    }

    func verificarRespuesta() {
        guard let pregunta = preguntaActual else { return }
        let entrada = respuestaTexto.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correcta = pregunta.r.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if entrada == correcta {
            explicacionMostrada = pregunta.exp
            progress.xp += dobleXPActivo ? 20 : 10
            feedback = "¡Excelente! 🎉"
            feedbackEsError = false
            mostrarModalCorrecto = true
        } else {
            progress.vidas -= 1
            if progress.vidas <= 0 {
                progress.nivelMaximo = max(1, progress.nivelMaximo - 3)
                progress.vidas = 3
                mostrarModalDerrota = true
            } else {
                feedback = "Incorrecto ❌ Inténtalo de nuevo."
                feedbackEsError = true
            }
        }
    }

    func continuar() {
        mostrarModalCorrecto = false
        if nivelEnJuego == progress.nivelMaximo && progress.nivelMaximo < maxNivel {
            progress.nivelMaximo += 1
        }
        if nivelEnJuego < maxNivel {
            iniciarNivel(nivelEnJuego + 1)
        } else {
            progress.otorgarInsigniaRama(rama)
            mostrarRamaCompletada = true
        }
    }

    @discardableResult
    func usarBooster(_ tipo: BoosterTipo) -> Bool {
        guard progress.cantidad(de: tipo) > 0 else { return false }
        guard let pregunta = preguntaActual else { return false }

        switch tipo {
        case .pista:
            pistaMostrada = pregunta.pista
        case .resolver:
            respuestaTexto = pregunta.r
            verificarRespuesta()
        case .vida:
            progress.vidas += 1
        case .doblexp:
            dobleXPActivo = true
        case .saltar:
            continuar()
        }

        progress.ajustar(tipo, por: -1)
        return true
    }
}
