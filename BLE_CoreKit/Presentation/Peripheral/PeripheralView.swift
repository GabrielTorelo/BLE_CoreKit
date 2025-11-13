import SwiftUI

struct PeripheralView: View {
    @StateObject var viewModel: PeripheralViewModel

    var body: some View {
        VStack(spacing: 0) {

            StatusBanner(
                message: viewModel.bluetoothStateMessage,
                isConnected: viewModel.bluetoothStateMessage == "Pronto para anunciar"
            )

            Form {
                Section(header: Label("Configurações do Simulador", systemImage: "slider.horizontal.3")) {
                    
                    TextField("Nome do Dispositivo", text: $viewModel.deviceName)

                    VStack(spacing: 8) {
                        Text("Valor do Sensor")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(Int(viewModel.sensorValue))")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.green)

                        Slider(value: $viewModel.sensorValue, in: 0...255, step: 1.0)
                            .tint(.green)
                    }
                    .padding(.vertical, 10)
                }

                Section(header: Label("Log de Eventos", systemImage: "list.bullet.clipboard.fill")) {
                    List(viewModel.logMessages.reversed(), id: \.self) { msg in
                        Text(msg)
                            .font(.caption)
                    }
                    .frame(height: 200)
                }
            }
            .listStyle(InsetGroupedListStyle())

            Button(action: viewModel.toggleAdvertising) {
                HStack(spacing: 10) {
                    if viewModel.isAdvertising {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                    }

                    Text(viewModel.isAdvertising ? "Anunciando..." : "Iniciar Anúncio")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: viewModel.isAdvertising ? [.red, .orange] : [.green, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(
                    color: (viewModel.isAdvertising ? Color.red : Color.green).opacity(0.4),
                    radius: 8,
                    y: 4
                )
            }
            .padding([.horizontal, .bottom])
            .disabled(
                !(viewModel.bluetoothStateMessage == "Pronto para anunciar")
            )
            .animation(.easeInOut, value: viewModel.isAdvertising)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Periférico")
    }
}
