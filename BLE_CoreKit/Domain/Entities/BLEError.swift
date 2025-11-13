import Foundation

enum BLEError: Error, LocalizedError {
    case poweredOff
    case unauthorized
    case connectionFailed(Error?)
    case readFailed(Error?)
    case writeFailed(Error?)
    case subscribeFailed(Error?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .poweredOff: return "Bluetooth está desligado."
        case .unauthorized: return "Bluetooth não autorizado."
        case .connectionFailed: return "Falha ao conectar."
        case .readFailed: return "Falha ao ler característica."
        case .writeFailed: return "Falha ao escrever característica."
        case .subscribeFailed: return "Falha ao se inscrever."
        case .unknown: return "Ocorreu um erro desconhecido."
        }
    }
}
