import SwiftUI

struct DeviceRowView: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Text(device.id.uuidString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: device.signalInfo.name)
                    .font(.subheadline)
                    .foregroundStyle(device.signalInfo.color)

                Text(device.rssiString)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}
