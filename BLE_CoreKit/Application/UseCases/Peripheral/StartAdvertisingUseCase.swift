import Foundation
import Combine
import CoreBluetooth

class StartAdvertisingUseCase {
    private let repository: BLEPeripheralRepositoryProtocol
    
    init(repository: BLEPeripheralRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() {
        repository.startAdvertising()
    }
    
    func stop() {
        repository.stopAdvertising()
    }
    
    func getStatePublisher() -> AnyPublisher<CBManagerState, Never> {
        repository.statePublisher
    }
    
    func getWriteRequestPublisher() -> AnyPublisher<(CBUUID, Data?), Never> {
        repository.writeRequestPublisher
    }
}
