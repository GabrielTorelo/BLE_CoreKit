import Foundation
import Combine
import CoreBluetooth

class ReadCharacteristicUseCase {
    private let repository: BLECentralRepositoryProtocol
    
    init(repository: BLECentralRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(uuid: CBUUID) {
        repository.readValue(for: uuid)
    }
    
    func getValuePublisher() -> AnyPublisher<(CBUUID, Data), BLEError> {
        repository.characteristicValuePublisher
    }
}
