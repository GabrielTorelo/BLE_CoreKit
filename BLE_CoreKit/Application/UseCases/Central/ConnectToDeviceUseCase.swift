import Foundation
import Combine
import CoreBluetooth

class ConnectToDeviceUseCase {
    private let repository: BLECentralRepositoryProtocol
    
    init(repository: BLECentralRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(device: Device) {
        repository.connect(to: device)
    }
    
    func disconnect(device: Device) {
        repository.disconnect(from: device)
    }
    
    func getConnectedDevicePublisher() -> AnyPublisher<Device?, Never> {
        repository.connectedDevicePublisher
    }
}
