import Foundation
import CoreBluetooth

class WriteCharacteristicUseCase {
    private let repository: BLECentralRepositoryProtocol
    
    init(repository: BLECentralRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(data: Data, uuid: CBUUID, type: CBCharacteristicWriteType) {
        repository.writeValue(data: data, for: uuid, type: type)
    }
}
