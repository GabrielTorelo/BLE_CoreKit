import Foundation
import Combine
import CoreBluetooth

class DeviceDetailViewModel: ObservableObject {
    @Published var device: Device?
    @Published var deviceName: String = "Carregando..."
    @Published var sensorValue: Int = 0
    @Published var commandLog: String = ""
    @Published var isSubscribed: Bool = false
    private let connectUseCase: ConnectToDeviceUseCase
    private let readUseCase: ReadCharacteristicUseCase
    private let writeUseCase: WriteCharacteristicUseCase
    private let subscribeUseCase: SubscribeToCharacteristicUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(injector: DependencyInjector, device: Device?, connectUseCase: ConnectToDeviceUseCase) {
        self.device = device
        self.connectUseCase = connectUseCase
        self.readUseCase = injector.makeReadCharacteristicUseCase()
        self.writeUseCase = injector.makeWriteCharacteristicUseCase()
        self.subscribeUseCase = injector.makeSubscribeToCharacteristicUseCase()
        
        setupBindings()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.readDeviceName()
            self.readSensorValue()
        }
    }
    
    private func setupBindings() {
        readUseCase.getValuePublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { [weak self] (uuid, data) in
                self?.handleReceivedData(uuid: uuid, data: data)
            })
            .store(in: &cancellables)
    }
    
    private func handleReceivedData(uuid: CBUUID, data: Data) {
        switch uuid {
            case BLEConstants.deviceNameCharacteristicUUID:
                self.deviceName = String(
                    data: data,
                    encoding: .utf8
                ) ?? "Erro de encoding"
                
            case BLEConstants.sensorValueCharacteristicUUID:
                let value = data.withUnsafeBytes { $0.load(as: UInt8.self) }
                self.sensorValue = Int(value)
                
            default: break
        }
    }
    
    func readDeviceName() {
        readUseCase.execute(
            uuid: BLEConstants.deviceNameCharacteristicUUID
        )
    }
    
    func writeDeviceName(name: String) {
        guard let data = name.data(using: .utf8) else { return }

        writeUseCase.execute(
            data: data,
            uuid: BLEConstants.deviceNameCharacteristicUUID,
            type: .withResponse
        )
    }
    
    func readSensorValue() {
        readUseCase.execute(
            uuid: BLEConstants.sensorValueCharacteristicUUID
        )
    }
    
    func toggleSubscription() {
        isSubscribed.toggle()
        
        if isSubscribed {
            subscribeUseCase.execute(
                uuid: BLEConstants.sensorValueCharacteristicUUID
            )
        } else {
            subscribeUseCase.stop(
                uuid: BLEConstants.sensorValueCharacteristicUUID
            )
        }
    }
    
    func sendCommand() {
        writeUseCase.execute(
            data: Data([0x01]),
            uuid: BLEConstants.commandCharacteristicUUID,
            type: .withoutResponse
        )
        
        commandLog = "Comando 0x01 enviado!"
    }
    
    func disconnect() {
        if let device = device {
            connectUseCase.disconnect(device: device)
        }
    }
}
