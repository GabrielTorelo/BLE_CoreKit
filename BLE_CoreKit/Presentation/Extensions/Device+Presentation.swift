import SwiftUI

extension Device {
    var signalInfo: (name: String, color: Color) {
        if rssi > -65 {
            return ("wifi", .green)
        } else if rssi > -85 {
            return ("wifi.medium", .orange)
        } else {
            return ("wifi.low", .red)
        }
    }

    var rssiString: String {
        return "\(rssi) dBm"
    }
}
