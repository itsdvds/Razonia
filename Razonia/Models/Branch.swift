import SwiftUI

enum RamaID: String, CaseIterable, Identifiable {
    case logica            = "logica"
    case fisica            = "fisica"
    case matematicas       = "matematicas"
    case musica            = "musica"
    case logicaComputacional = "logica_computacional"
    case filosofia         = "filosofia"
    case ajedrez           = "ajedrez"

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .logica:             return "Lógica"
        case .fisica:             return "Física"
        case .matematicas:        return "Matemáticas"
        case .musica:             return "Música"
        case .logicaComputacional:return "Lóg. Computacional"
        case .filosofia:          return "Filosofía"
        case .ajedrez:            return "Ajedrez"
        }
    }

    var emoji: String {
        switch self {
        case .logica:             return "🧩"
        case .fisica:             return "⚛️"
        case .matematicas:        return "📐"
        case .musica:             return "🎵"
        case .logicaComputacional:return "💻"
        case .filosofia:          return "🦉"
        case .ajedrez:            return "♟️"
        }
    }

    var jsonName: String {
        switch self {
        case .logica:             return "niveles"
        case .fisica:             return "niveles_fisica"
        case .matematicas:        return "niveles_matematicas"
        case .musica:             return "niveles_musica"
        case .logicaComputacional:return "niveles_logica_computacional"
        case .filosofia:          return "niveles_filosofia"
        case .ajedrez:            return "niveles_ajedrez"
        }
    }

    var colorPrincipal: Color {
        switch self {
        case .logica:             return Color("razoniaPurple")
        case .fisica:             return Color("razoniaGreen")
        case .matematicas:        return Color("razoniaCyan")
        case .musica:             return Color("razoniaViolet")
        case .logicaComputacional:return Color("razoniaGold")
        case .filosofia:          return Color("razoniaPink")
        case .ajedrez:            return Color("razoniaRed")
        }
    }

    var gradiente: [Color] {
        switch self {
        case .logica:
            return [Color(red: 0.7, green: 0.2, blue: 1.0), Color(red: 0.9, green: 0.1, blue: 0.4)]
        case .fisica:
            return [Color(red: 0.1, green: 0.8, blue: 0.3), Color(red: 0.0, green: 0.5, blue: 0.15)]
        case .matematicas:
            return [Color(red: 0.0, green: 0.8, blue: 0.9), Color(red: 0.0, green: 0.5, blue: 0.7)]
        case .musica:
            return [Color(red: 0.6, green: 0.1, blue: 0.9), Color(red: 0.4, green: 0.0, blue: 0.6)]
        case .logicaComputacional:
            return [Color(red: 1.0, green: 0.75, blue: 0.0), Color(red: 0.8, green: 0.45, blue: 0.0)]
        case .filosofia:
            return [Color(red: 1.0, green: 0.3, blue: 0.6), Color(red: 0.8, green: 0.0, blue: 0.35)]
        case .ajedrez:
            return [Color(red: 0.9, green: 0.1, blue: 0.15), Color(red: 0.6, green: 0.0, blue: 0.05)]
        }
    }

    var colorBorde: Color {
        gradiente[0].opacity(0.7)
    }
}
