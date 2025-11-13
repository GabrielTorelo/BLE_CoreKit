import SwiftUI

struct StatusBanner: View {
    let message: String
    let isConnected: Bool

    var body: some View {
        let color: Color = isConnected ? .green : .red

        HStack {
            Image(systemName: isConnected ? "antenna.radiowaves.left.and.right" : "exclamationmark.triangle.fill")
                .font(.callout.weight(.bold))
            
            Text(message)
                .font(.callout)
                .fontWeight(.medium)
        }
        .foregroundStyle(isConnected ? .green : .red)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background((isConnected ? Color.green : Color.red).opacity(0.1))
        .clipShape(Capsule())
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}
