import Foundation

struct Pregunta: Codable, Identifiable {
    var id: String { p }
    let p: String       // pregunta
    let r: String       // respuesta correcta
    let exp: String     // explicación
    let pista: String   // hint
}

struct NivelData: Codable {
    let nivel: Int
    let preguntas: [Pregunta]
}

enum BoosterTipo: String, CaseIterable, Identifiable {
    case pista    = "pista"
    case resolver = "resolver"
    case vida     = "vida"
    case doblexp  = "doblexp"
    case saltar   = "saltar"

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .pista:    return "Pista"
        case .resolver: return "Resolver"
        case .vida:     return "Vida"
        case .doblexp:  return "Doble XP"
        case .saltar:   return "Saltar"
        }
    }

    var icono: String {
        switch self {
        case .pista:    return "lightbulb.fill"
        case .resolver: return "checkmark.seal.fill"
        case .vida:     return "heart.fill"
        case .doblexp:  return "bolt.fill"
        case .saltar:   return "forward.fill"
        }
    }

    var descripcion: String {
        switch self {
        case .pista:    return "Muestra una pista para la pregunta actual"
        case .resolver: return "Resuelve automáticamente la pregunta"
        case .vida:     return "Recupera una vida"
        case .doblexp:  return "Gana el doble de XP en la próxima respuesta"
        case .saltar:   return "Salta al siguiente nivel sin responder"
        }
    }
}

enum NivelesStore {
    private static var nivelMap: [Int: [Pregunta]] = {
        guard let url = Bundle.main.url(forResource: "niveles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([NivelData].self, from: data)
        else { return [:] }
        return Dictionary(uniqueKeysWithValues: decoded.map { ($0.nivel, $0.preguntas) })
    }()

    static func preguntaAleatoria(nivel: Int) -> Pregunta? {
        nivelMap[nivel]?.randomElement()
    }
}
