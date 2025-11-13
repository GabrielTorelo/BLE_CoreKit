import SwiftUI

struct DeviceDetailView: View {
    @StateObject var viewModel: DeviceDetailViewModel
    @State private var newDeviceName: String = ""

    var body: some View {
        VStack(spacing: 0) {

            DeviceHeaderView(
                name: viewModel.device?.name ?? "Desconhecido",
                uuid: viewModel.device?.id.uuidString ?? "N/A"
            )

            Form {
                Section {
                    VStack(spacing: 8) {
                        Text("VALOR DO SENSOR")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Text("\(viewModel.sensorValue) ºC")
                            .font(
                                .system(
                                    size: 50,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Section(header: Label("Controle do Sensor", systemImage: "gauge.medium")) {
                    Toggle("Inscrever-se (Notify)", isOn: $viewModel.isSubscribed)
                        .tint(.blue)
                        .onChange(of: viewModel.isSubscribed) { _ in
                            viewModel.toggleSubscription()
                        }

                    Button(action: viewModel.readSensorValue) {
                        Label("Ler Valor (Manual)", systemImage: "arrow.clockwise")
                            .foregroundStyle(.blue)
                    }
                }

                Section(header: Label("Alterar Nome (Write)", systemImage: "pencil.line")) {
                    Text("Nome Atual: \(viewModel.deviceName)")
                        .font(.subheadline)

                    TextField("Novo nome", text: $newDeviceName)
                        .autocapitalization(.none)

                    Button(action: {
                        viewModel.writeDeviceName(name: newDeviceName)
                        newDeviceName = ""
                        hideKeyboard()
                    }) {
                        Label("Atualizar Nome", systemImage: "checkmark.circle.fill")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(newDeviceName.isEmpty)
                }

                Section(header: Label("Comandos", systemImage: "bolt.fill")) {
                    Button(action: viewModel.sendCommand) {
                        Label("Enviar Comando", systemImage: "sparkles")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if !viewModel.commandLog.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Último Envio:")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(viewModel.commandLog)
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Painel de Controle")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.disconnect()
        }
    }
}
