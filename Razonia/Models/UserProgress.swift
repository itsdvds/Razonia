import Foundation
import SwiftData

@Model
final class UserProgress {
    var username: String
    var nombre: String
    var passwordHash: String
    var xp: Int
    var nivelMaximo: Int
    var vidas: Int
    var insigniaRazonia: Bool
    var insigniaHackerPensamiento: Bool
    var insigniaLogica: Bool = false
    var insigniaFisica: Bool = false
    var insigniaMatematicas: Bool = false
    var insigniaMusica: Bool = false
    var insigniaLogicaComputacional: Bool = false
    var insigniaFilosofia: Bool = false
    var insigniaAjedrez: Bool = false
    
    var profileIconName: String?
    // 1. AÑADE ESTA NUEVA LÍNEA:
    var profileColorName: String?

    // Boosters
    var cantidadPistas: Int
    var cantidadResolver: Int
    var cantidadVidas: Int
    var cantidadDobleXP: Int
    var cantidadSaltar: Int

    init(
        username: String,
        nombre: String,
        passwordHash: String,
        xp: Int = 0,
        nivelMaximo: Int = 1,
        vidas: Int = 3,
        insigniaRazonia: Bool = false,
        insigniaHackerPensamiento: Bool = false,
        insigniaLogica: Bool = false,
        insigniaFisica: Bool = false,
        insigniaMatematicas: Bool = false,
        insigniaMusica: Bool = false,
        insigniaLogicaComputacional: Bool = false,
        insigniaFilosofia: Bool = false,
        insigniaAjedrez: Bool = false,
        profileIconName: String? = nil,
        profileColorName: String? = "purple", // Color inicial por defecto
        cantidadPistas: Int = 3,
        cantidadResolver: Int = 1,
        cantidadVidas: Int = 2,
        cantidadDobleXP: Int = 2,
        cantidadSaltar: Int = 1
    ) {
        self.username = username
        self.nombre = nombre
        self.passwordHash = passwordHash
        self.xp = xp
        self.nivelMaximo = nivelMaximo
        self.vidas = vidas
        self.insigniaRazonia = insigniaRazonia
        self.insigniaHackerPensamiento = insigniaHackerPensamiento
        self.insigniaLogica = insigniaLogica
        self.insigniaFisica = insigniaFisica
        self.insigniaMatematicas = insigniaMatematicas
        self.insigniaMusica = insigniaMusica
        self.insigniaLogicaComputacional = insigniaLogicaComputacional
        self.insigniaFilosofia = insigniaFilosofia
        self.insigniaAjedrez = insigniaAjedrez
        self.profileIconName = profileIconName
        self.profileColorName = profileColorName // Inicialización
        self.cantidadPistas = cantidadPistas
        self.cantidadResolver = cantidadResolver
        self.cantidadVidas = cantidadVidas
        self.cantidadDobleXP = cantidadDobleXP
        self.cantidadSaltar = cantidadSaltar
    }

    func cantidad(de tipo: BoosterTipo) -> Int {
        switch tipo {
        case .pista:    return cantidadPistas
        case .resolver: return cantidadResolver
        case .vida:     return cantidadVidas
        case .doblexp:  return cantidadDobleXP
        case .saltar:   return cantidadSaltar
        }
    }

    func ajustar(_ tipo: BoosterTipo, por delta: Int) {
        switch tipo {
        case .pista:    cantidadPistas    = max(0, cantidadPistas + delta)
        case .resolver: cantidadResolver  = max(0, cantidadResolver + delta)
        case .vida:     cantidadVidas     = max(0, cantidadVidas + delta)
        case .doblexp:  cantidadDobleXP   = max(0, cantidadDobleXP + delta)
        case .saltar:   cantidadSaltar    = max(0, cantidadSaltar + delta)
        }
    }

    func otorgarInsigniaRama(_ rama: RamaID) {
        switch rama {
        case .logica: insigniaLogica = true
        case .fisica: insigniaFisica = true
        case .matematicas: insigniaMatematicas = true
        case .musica: insigniaMusica = true
        case .logicaComputacional: insigniaLogicaComputacional = true
        case .filosofia: insigniaFilosofia = true
        case .ajedrez: insigniaAjedrez = true
        }
        evaluarInsigniaRazoniaGlobal()
    }

    func tieneInsigniaRama(_ rama: RamaID) -> Bool {
        switch rama {
        case .logica: return insigniaLogica
        case .fisica: return insigniaFisica
        case .matematicas: return insigniaMatematicas
        case .musica: return insigniaMusica
        case .logicaComputacional: return insigniaLogicaComputacional
        case .filosofia: return insigniaFilosofia
        case .ajedrez: return insigniaAjedrez
        }
    }

    @discardableResult
    func evaluarInsigniaRazoniaGlobal() -> Bool {
        let completo = insigniaLogica
            && insigniaFisica
            && insigniaMatematicas
            && insigniaMusica
            && insigniaLogicaComputacional
            && insigniaFilosofia
            && insigniaAjedrez
        if completo && !insigniaRazonia {
            insigniaRazonia = true
            cantidadPistas += 5
            cantidadResolver += 3
            cantidadVidas += 3
            cantidadDobleXP += 3
            cantidadSaltar += 2
        }
        return completo
    }

    func aplicarRecompensaLogica() {
        insigniaLogica = true
        cantidadPistas    += 5
        cantidadResolver  += 3
        cantidadVidas     += 3
        cantidadDobleXP   += 3
        cantidadSaltar    += 2
        evaluarInsigniaRazoniaGlobal()
    }

    var rango: String {
        switch nivelMaximo {
        case 1..<10:   return "Aprendiz"
        case 10..<25:  return "Explorador"
        case 25..<50:  return "Pensador"
        case 50..<75:  return "Razonador"
        case 75..<90:  return "Maestro"
        case 90..<120: return "Razonia"
        default:       return "Hacker del Pensamiento"
        }
    }
}
