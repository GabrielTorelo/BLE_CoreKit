import Foundation
import CoreBluetooth

class UpdateCharacteristicValueUseCase {
    private let repository: BLEPeripheralRepositoryProtocol
    
    init(repository: BLEPeripheralRepositoryProtocol) {
        self.repository = repository
    }
    
    @discardableResult
    func execute(uuid: CBUUID, data: Data) -> Bool {
        repository.updateCharacteristicValue(uuid: uuid, data: data)
    }
}
