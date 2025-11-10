import Foundation
import CoreBluetooth

class SubscribeToCharacteristicUseCase {
    private let repository: BLECentralRepositoryProtocol
    
    init(repository: BLECentralRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(uuid: CBUUID) {
        repository.subscribeToNotifications(for: uuid)
    }
    
    func stop(uuid: CBUUID) {
        repository.unsubscribeFromNotifications(for: uuid)
    }
}
