import Foundation
import CoreBluetooth

struct Device: Identifiable, Hashable {
    let id: UUID
    let peripheral: CBPeripheral
    var name: String
    var rssi: Int
    var state: CBPeripheralState = .disconnected

    static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
