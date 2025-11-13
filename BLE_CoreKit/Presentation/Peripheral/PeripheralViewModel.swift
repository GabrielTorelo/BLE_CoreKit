import Foundation
import Combine
import CoreBluetooth

class PeripheralViewModel: ObservableObject {
    @Published var isAdvertising = false
    @Published var bluetoothStateMessage: String = "Aguardando Bluetooth..."
    @Published var logMessages = [String]()
    @Published var deviceName: String = "Não Conectado"
    @Published var sensorValue: Double = 0.0
    private let startAdvUseCase: StartAdvertisingUseCase
    private let updateValueUseCase: UpdateCharacteristicValueUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(injector: DependencyInjector) {
        self.startAdvUseCase = injector.makeStartAdvertisingUseCase()
        self.updateValueUseCase = injector.makeUpdateCharacteristicValueUseCase()

        setupBindings()
    }

    private func setupBindings() {
        startAdvUseCase.getStatePublisher()
            .map { state -> String in
                switch state {
                case .poweredOn: return "Pronto para anunciar"
                case .poweredOff: return "Bluetooth Desligado"
                case .unauthorized: return "Bluetooth Não Autorizado"
                default: return "Aguardando Bluetooth..."
                }
            }
            .assign(to: &$bluetoothStateMessage)

        startAdvUseCase.getWriteRequestPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (uuid, data) in
                self?.handleWriteRequest(uuid: uuid, data: data)
            }
            .store(in: &cancellables)

        $deviceName
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] name in
                self?.updateLocalCharacteristic(uuid: BLEConstants.deviceNameCharacteristicUUID,
                                                data: name.data(using: .utf8) ?? Data())
            }
            .store(in: &cancellables)

        $sensorValue
            .map { UInt8($0) }
            .sink { [weak self] byteValue in
                self?.updateLocalCharacteristic(uuid: BLEConstants.sensorValueCharacteristicUUID,
                                                data: Data([byteValue]))
            }
            .store(in: &cancellables)
    }

    func toggleAdvertising() {
        isAdvertising.toggle()

        if isAdvertising {
            startAdvUseCase.execute()
            addLog("Anunciando serviço...")
        } else {
            startAdvUseCase.stop()
            addLog("Advertising parado.")
        }
    }

    private func addLog(_ message: String) {
        logMessages.insert(message, at: 0)
    }

    private func handleWriteRequest(uuid: CBUUID, data: Data?) {
        guard let data = data else { return }

        switch uuid {
            case BLEConstants.deviceNameCharacteristicUUID:
                let receivedName = String(data: data, encoding: .utf8) ?? "N/A"
                self.deviceName = receivedName
                addLog("Central atualizou o nome para: \(receivedName)")
                
            case BLEConstants.commandCharacteristicUUID:
                let command = data.withUnsafeBytes { $0.load(as: UInt8.self) }
                addLog("Comando recebido: 0x\(String(format: "%02x", command))")
                
            default: break
        }
    }
    
    private func updateLocalCharacteristic(uuid: CBUUID, data: Data) {
        let success = updateValueUseCase.execute(uuid: uuid, data: data)

        if uuid == BLEConstants.sensorValueCharacteristicUUID && success {
            addLog("Notificação enviada: \(data.withUnsafeBytes { $0.load(as: UInt8.self) })")
        }
    }
}
