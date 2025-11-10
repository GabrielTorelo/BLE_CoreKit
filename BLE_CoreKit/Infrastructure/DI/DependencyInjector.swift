import Foundation

class DependencyInjector {
    static let shared = DependencyInjector()

    lazy var bleCentralRepository: BLECentralRepositoryProtocol = BLECentralRepository()
    lazy var blePeripheralRepository: BLEPeripheralRepositoryProtocol = BLEPeripheralRepository()
    
    private init() {}
    
    func makeScanForDevicesUseCase() -> ScanForDevicesUseCase {
        ScanForDevicesUseCase(repository: bleCentralRepository)
    }
    
    func makeConnectToDeviceUseCase() -> ConnectToDeviceUseCase {
        ConnectToDeviceUseCase(repository: bleCentralRepository)
    }
    
    func makeReadCharacteristicUseCase() -> ReadCharacteristicUseCase {
        ReadCharacteristicUseCase(repository: bleCentralRepository)
    }
    
    func makeWriteCharacteristicUseCase() -> WriteCharacteristicUseCase {
        WriteCharacteristicUseCase(repository: bleCentralRepository)
    }
    
    func makeSubscribeToCharacteristicUseCase() -> SubscribeToCharacteristicUseCase {
        SubscribeToCharacteristicUseCase(repository: bleCentralRepository)
    }
    
    func makeStartAdvertisingUseCase() -> StartAdvertisingUseCase {
        StartAdvertisingUseCase(repository: blePeripheralRepository)
    }
    
    func makeUpdateCharacteristicValueUseCase() -> UpdateCharacteristicValueUseCase {
        UpdateCharacteristicValueUseCase(repository: blePeripheralRepository)
    }
}
