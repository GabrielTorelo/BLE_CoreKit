import Foundation
import Combine
import CoreBluetooth

protocol BLEPeripheralRepositoryProtocol {
    var statePublisher: AnyPublisher<CBManagerState, Never> { get }
    var writeRequestPublisher: AnyPublisher<(CBUUID, Data?), Never> { get }

    func startAdvertising()
    func stopAdvertising()
    func updateCharacteristicValue(uuid: CBUUID, data: Data) -> Bool
}
