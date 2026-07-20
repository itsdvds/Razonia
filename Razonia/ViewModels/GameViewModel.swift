import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - Modelos de mapeo para tu estructura JSON exacta
struct NivelJSON: Codable, Identifiable {
    var id: Int { nivel } // Satisface el protocolo Identifiable usando el número de nivel
    let nivel: Int
    let preguntas: [PreguntaJSON]
}

struct PreguntaJSON: Codable {
    let p: String     // Enunciado
    let r: String     // Respuesta correcta
    let exp: String   // Explicación analítica
    let pista: String // Pista de ayuda
}

@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Estado del juego publicado
    @Published var nivelEnJuego: Int = 1
    @Published var preguntaActual: PreguntaJSON?
    @Published var respuestaTexto: String = ""
    @Published var feedback: String = ""
    @Published var feedbackEsError: Bool = false

    @Published var mostrarModalCorrecto = false
    @Published var mostrarModalDerrota = false
    @Published var mostrarVictoria = false   // Razonamiento lógico completado (nivel 90)
    @Published var mostrarHacker = false     // Zona extrema completada (nivel 120)

    @Published var dobleXPActivo = false
    @Published var pistaMostrada: String?
    @Published var explicacionMostrada: String?

    // Colección de todos los niveles cargados desde el JSON
    private var todosLosNiveles: [NivelJSON] = []
    private var indicePreguntaActual: Int = 0

    let maxNivel = 120
    let umbralRazonia = 90

    // MARK: - Dependencias
    private var progress: UserProgress

    init(progress: UserProgress) {
        self.progress = progress
        cargarNivelesDesdeJSON()
    }

    func actualizar(progress: UserProgress) {
        self.progress = progress
    }

    // MARK: - Decodificador del archivo JSON
    private func cargarNivelesDesdeJSON() {
        guard let url = Bundle.main.url(forResource: "niveles", withExtension: "json") else {
            print("❌ Error: No se encontró el archivo 'niveles.json' en el Bundle de la App.")
            self.feedback = "Falta archivo niveles.json"
            self.feedbackEsError = true
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.todosLosNiveles = try decoder.decode([NivelJSON].self, from: data)
            print("✅ JSON cargado con éxito. Total de niveles cargados: \(todosLosNiveles.count)")
        } catch {
            print("❌ Error de parsing en el JSON: \(error)")
            self.feedback = "Error al leer JSON"
            self.feedbackEsError = true
        }
    }

    // MARK: - Control de Flujo del Nivel
    func iniciarNivel(_ numero: Int) {
        self.nivelEnJuego = numero
        self.respuestaTexto = ""
        self.feedback = ""
        self.pistaMostrada = nil
        self.explicacionMostrada = nil
        self.dobleXPActivo = false

        // Busca el nivel correspondiente en el JSON mapeado
        if let nivelObjetivo = todosLosNiveles.first(where: { $0.nivel == numero }) {
            if !nivelObjetivo.preguntas.isEmpty {
                // CAMBIO: Selecciona un índice totalmente aleatorio del banco de preguntas del nivel
                self.indicePreguntaActual = Int.random(in: 0..<nivelObjetivo.preguntas.count)
                self.preguntaActual = nivelObjetivo.preguntas[self.indicePreguntaActual]
            } else {
                print("⚠️ El nivel \(numero) existe en el JSON pero no tiene preguntas.")
                self.preguntaActual = nil
            }
        } else {
            print("❌ El nivel \(numero) no se encontró dentro del JSON cargado.")
            self.preguntaActual = nil
        }
    }

    var tituloNivel: String {
        nivelEnJuego > umbralRazonia ? "Extremo \(nivelEnJuego - umbralRazonia)" : "Nivel \(nivelEnJuego)"
    }

    // MARK: - Validación de Respuestas (Formateo tolerante)
    func verificarRespuesta() {
        guard let pregunta = preguntaActual else { return }

        let entradaUser = respuestaTexto.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let solucionCorrecta = pregunta.r.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if entradaUser == solucionCorrecta {
            self.explicacionMostrada = pregunta.exp
            
            let recompensaBase = nivelEnJuego > umbralRazonia ? 20 : 10
            let multiplicador = dobleXPActivo ? 2 : 1
            progress.xp += (recompensaBase * multiplicador)

            feedback = "¡Excelente! 🎉"
            feedbackEsError = false
            mostrarModalCorrecto = true
        } else {
            // Manejo de penalización de vidas
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
        
        // CAMBIO: Se eliminó el bloque que iteraba el sub-arreglo. Al acertar una pregunta,
        // avanzamos directamente el nivel en el progreso global e iniciamos el siguiente nivel.
        if nivelEnJuego == progress.nivelMaximo && progress.nivelMaximo < maxNivel {
            progress.nivelMaximo += 1
        }

        // Determinar la pantalla de cierre o cargar el nivel consecutivo
        if nivelEnJuego == umbralRazonia {
            progress.aplicarRecompensaLogica()
            mostrarVictoria = true
        } else if nivelEnJuego >= maxNivel {
            progress.insigniaHackerPensamiento = true
            mostrarHacker = true
        } else {
            iniciarNivel(nivelEnJuego + 1)
        }
    }

    // MARK: - Gestión de Items / Boosters
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
