import Foundation
import CoreBluetooth

struct BLEConstants {
    static let serviceUUID = CBUUID(
        string: "4A981B28-766E-464A-A85F-A3258833489A"
    )

    static let deviceNameCharacteristicUUID = CBUUID(
        string: "A6F8F39D-834B-4E9A-96D5-3E7C979E31FF"
    )

    static let sensorValueCharacteristicUUID = CBUUID(
        string: "4A067F1F-B138-4C88-A48E-B715C421C007"
    )

    static let commandCharacteristicUUID = CBUUID(
        string: "68C4FEA3-1C77-4B24-B1AF-EAF1E71F3689"
    )
}
