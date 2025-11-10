import Foundation
import Combine
import CoreBluetooth

protocol BLECentralRepositoryProtocol {
    var statePublisher: AnyPublisher<CBManagerState, Never> { get }
    var discoveredDevicesPublisher: AnyPublisher<[Device], Never> { get }
    var connectedDevicePublisher: AnyPublisher<Device?, Never> { get }
    var characteristicValuePublisher: AnyPublisher<(CBUUID, Data), BLEError> { get }

    func startScan()
    func stopScan()
    func connect(to device: Device)
    func disconnect(from device: Device)
    
    func readValue(for characteristicUUID: CBUUID)
    func writeValue(data: Data, for characteristicUUID: CBUUID, type: CBCharacteristicWriteType)
    func subscribeToNotifications(for characteristicUUID: CBUUID)
    func unsubscribeFromNotifications(for characteristicUUID: CBUUID)
}
