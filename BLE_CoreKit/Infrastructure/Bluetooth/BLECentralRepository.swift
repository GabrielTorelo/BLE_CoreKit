import Foundation
import CoreBluetooth
import Combine

class BLECentralRepository: NSObject, BLECentralRepositoryProtocol, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var discoveredCharacteristics = [CBUUID: CBCharacteristic]()
    private let stateSubject = PassthroughSubject<CBManagerState, Never>()
    private let discoveredDevicesSubject = CurrentValueSubject<[Device], Never>([])
    private let connectedDeviceSubject = CurrentValueSubject<Device?, Never>(nil)
    private let characteristicValueSubject = PassthroughSubject<(CBUUID, Data), BLEError>()

    var statePublisher: AnyPublisher<CBManagerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    var discoveredDevicesPublisher: AnyPublisher<[Device], Never> {
        discoveredDevicesSubject.eraseToAnyPublisher()
    }
    
    var connectedDevicePublisher: AnyPublisher<Device?, Never> {
        connectedDeviceSubject.eraseToAnyPublisher()
    }
    
    var characteristicValuePublisher: AnyPublisher<(CBUUID, Data), BLEError> {
        characteristicValueSubject.eraseToAnyPublisher()
    }

    private var devicesList = [Device]()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        guard centralManager.state == .poweredOn else { return }

        devicesList.removeAll()
        discoveredDevicesSubject.send(devicesList)

        centralManager.scanForPeripherals(withServices: [BLEConstants.serviceUUID], options: nil)
    }

    func stopScan() {
        centralManager.stopScan()
    }

    func connect(to device: Device) {
        centralManager.connect(device.peripheral, options: nil)
    }

    func disconnect(from device: Device) {
        centralManager.cancelPeripheralConnection(device.peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)

        if central.state != .poweredOn {
            devicesList.removeAll()
            discoveredDevicesSubject.send(devicesList)
            connectedDeviceSubject.send(nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !devicesList.contains(where: { $0.id == peripheral.identifier }) {
            let device = Device(
                id: peripheral.identifier,
                peripheral: peripheral,
                name: advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "Desconhecido",
                rssi: RSSI.intValue
            )
            
            devicesList.append(device)
            discoveredDevicesSubject.send(devicesList)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopScan()

        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self

        if let index = devicesList.firstIndex(where: { $0.id == peripheral.identifier }) {
            devicesList[index].state = .connected
            connectedDeviceSubject.send(devicesList[index])
        }

        peripheral.discoverServices([BLEConstants.serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        characteristicValueSubject.send(completion: .failure(.connectionFailed(error)))
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil

        discoveredCharacteristics.removeAll()
        connectedDeviceSubject.send(nil)
        
        if let index = devicesList.firstIndex(where: { $0.id == peripheral.identifier }) {
            devicesList[index].state = .disconnected
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services where service.uuid == BLEConstants.serviceUUID {
            peripheral.discoverCharacteristics([
                    BLEConstants.deviceNameCharacteristicUUID,
                    BLEConstants.sensorValueCharacteristicUUID,
                    BLEConstants.commandCharacteristicUUID
                ],
                for: service
            )
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for char in characteristics {
            discoveredCharacteristics[char.uuid] = char
        }
    }

    func readValue(for characteristicUUID: CBUUID) {
        guard let char = discoveredCharacteristics[characteristicUUID] else { return }
        connectedPeripheral?.readValue(for: char)
    }

    func writeValue(data: Data, for characteristicUUID: CBUUID, type: CBCharacteristicWriteType) {
        guard let char = discoveredCharacteristics[characteristicUUID] else { return }
        connectedPeripheral?.writeValue(data, for: char, type: type)
    }

    func subscribeToNotifications(for characteristicUUID: CBUUID) {
        guard let char = discoveredCharacteristics[characteristicUUID] else { return }
        connectedPeripheral?.setNotifyValue(true, for: char)
    }
    
    func unsubscribeFromNotifications(for characteristicUUID: CBUUID) {
        guard let char = discoveredCharacteristics[characteristicUUID] else { return }
        connectedPeripheral?.setNotifyValue(false, for: char)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            characteristicValueSubject.send(completion: .failure(.readFailed(error)))
            return
        }
        
        if let data = characteristic.value {
            characteristicValueSubject.send((characteristic.uuid, data))
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            characteristicValueSubject.send(completion: .failure(.writeFailed(error)))
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            characteristicValueSubject.send(completion: .failure(.subscribeFailed(error)))
        }
    }
}
