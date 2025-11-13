import SwiftUI

struct DeviceListView: View {
    @StateObject var viewModel: DeviceListViewModel

    var body: some View {
        VStack(spacing: 0) {

            BluetoothStatusBanner(
                message: viewModel.bluetoothStateMessage,
                isConnected: viewModel.bluetoothStateMessage == "Bluetooth Ligado"
            )
            .padding(.bottom, 10)

            List {
                ForEach(viewModel.devices) {
                    device in
                        DeviceRowView(device: device)
                            .onTapGesture {
                                viewModel.connect(to: device)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            .listStyle(.plain)

            NavigationLink(
                destination: DeviceDetailView(
                    viewModel: DeviceDetailViewModel(
                        injector: DependencyInjector.shared,
                        device: viewModel.selectedDevice,
                        connectUseCase: viewModel.connectUseCase
                    )
                ),
                isActive: $viewModel.navigateToDetail
            ) { EmptyView() }

            Button(action: viewModel.toggleScan) {
                HStack(spacing: 10) {
                    if viewModel.isScanning {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(viewModel.isScanning ? "Procurando..." : "Iniciar Scan")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: viewModel.isScanning ? [.red, .orange] : [.blue, .indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(
                    color: (viewModel.isScanning ? Color.red : Color.blue).opacity(0.4),
                    radius: 8,
                    y: 4
                )
            }
            .padding([.horizontal, .bottom])
            .disabled(viewModel.bluetoothStateMessage != "Bluetooth Ligado")
            .animation(.easeInOut, value: viewModel.isScanning)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Dispositivos")
        .onDisappear {
            viewModel.stopScan()
        }
    }
}
