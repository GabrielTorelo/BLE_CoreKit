import Foundation
import Combine
import CoreBluetooth

class ScanForDevicesUseCase {
    private let repository: BLECentralRepositoryProtocol
    
    init(repository: BLECentralRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[Device], Never> {
        repository.startScan()
        return repository.discoveredDevicesPublisher
    }
    
    func stop() {
        repository.stopScan()
    }
    
    func statePublisher() -> AnyPublisher<CBManagerState, Never> {
        repository.statePublisher
    }
}
