import Foundation
import CoreBluetooth
import Combine

class BLEPeripheralRepository: NSObject, BLEPeripheralRepositoryProtocol, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var deviceNameCharacteristic: CBMutableCharacteristic!
    private var sensorValueCharacteristic: CBMutableCharacteristic!
    private var commandCharacteristic: CBMutableCharacteristic!
    private let stateSubject = PassthroughSubject<CBManagerState, Never>()
    private let writeRequestSubject = PassthroughSubject<(CBUUID, Data?), Never>()

    var statePublisher: AnyPublisher<CBManagerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    var writeRequestPublisher: AnyPublisher<(CBUUID, Data?), Never> {
        writeRequestSubject.eraseToAnyPublisher()
    }
    
    private var subscribedCentrals = [CBCentral]()

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startAdvertising() {
        guard peripheralManager.state == .poweredOn else { return }
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [BLEConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: "Dispositivo Periférico"
        ]

        peripheralManager.startAdvertising(advertisementData)
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }

    func updateCharacteristicValue(uuid: CBUUID, data: Data) -> Bool {
        guard peripheralManager.state == .poweredOn else { return false }
        
        var characteristic: CBMutableCharacteristic?

        if uuid == BLEConstants.sensorValueCharacteristicUUID {
            characteristic = sensorValueCharacteristic
        } else if uuid == BLEConstants.deviceNameCharacteristicUUID {
            characteristic = deviceNameCharacteristic
        }
        
        guard let characteristic = characteristic else { return false }
        
        characteristic.value = data
        
        if uuid == BLEConstants.sensorValueCharacteristicUUID {
            return peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        }
        
        return true
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        stateSubject.send(peripheral.state)

        if peripheral.state == .poweredOn {
            setupServices()
        }
    }
    
    private func setupServices() {
        deviceNameCharacteristic = CBMutableCharacteristic(
            type: BLEConstants.deviceNameCharacteristicUUID,
            properties: [.read, .write],
            value: "Dispositivo Periférico".data(using: .utf8),
            permissions: [.readable, .writeable]
        )

        sensorValueCharacteristic = CBMutableCharacteristic(
            type: BLEConstants.sensorValueCharacteristicUUID,
            properties: [.read, .notify],
            value: Data([0]),
            permissions: [.readable]
        )

        commandCharacteristic = CBMutableCharacteristic(
            type: BLEConstants.commandCharacteristicUUID,
            properties: [.writeWithoutResponse],
            value: nil,
            permissions: [.writeable]
        )

        let service = CBMutableService(type: BLEConstants.serviceUUID, primary: true)

        service.characteristics = [
            deviceNameCharacteristic,
            sensorValueCharacteristic,
            commandCharacteristic
        ]

        peripheralManager.add(service)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        var characteristic: CBMutableCharacteristic?
        
        if request.characteristic.uuid == BLEConstants.deviceNameCharacteristicUUID {
            characteristic = deviceNameCharacteristic
        } else if request.characteristic.uuid == BLEConstants.sensorValueCharacteristicUUID {
            characteristic = sensorValueCharacteristic
        }
        
        guard let characteristic = characteristic else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
            return
        }

        if request.offset > (characteristic.value?.count ?? 0) {
            peripheral.respond(to: request, withResult: .invalidOffset)
            return
        }

        request.value = characteristic.value?.subdata(in: request.offset..<(characteristic.value?.count ?? 0))
        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            writeRequestSubject.send((request.characteristic.uuid, request.value))

            if request.characteristic.uuid == BLEConstants.deviceNameCharacteristicUUID {
                deviceNameCharacteristic.value = request.value
            } else if request.characteristic.uuid == BLEConstants.commandCharacteristicUUID {}

            if request.characteristic.properties.contains(.write) {
                 peripheral.respond(to: request, withResult: .success)
            }
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        if characteristic.uuid == BLEConstants.sensorValueCharacteristicUUID {
            subscribedCentrals.append(central)
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        if characteristic.uuid == BLEConstants.sensorValueCharacteristicUUID {
            subscribedCentrals.removeAll(where: { $0.identifier == central.identifier })
        }
    }
}
