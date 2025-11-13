import SwiftUI

struct BluetoothStatusBanner: View {
    let message: String
    let isConnected: Bool

    var body: some View {
        let color: Color = isConnected ? .green : .red

        HStack {
            Image(systemName: isConnected ? "bluetooth" : "exclamationmark.triangle.fill")
                .font(.callout.weight(.bold))

            Text(message)
                .font(.callout)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
        .padding(.top, 5)
    }
}
