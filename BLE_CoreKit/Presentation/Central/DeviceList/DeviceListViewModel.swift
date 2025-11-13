import Foundation
import Combine
import CoreBluetooth

class DeviceListViewModel: ObservableObject {
    @Published var devices = [Device]()
    @Published var selectedDevice: Device?
    @Published var isScanning = false
    @Published var bluetoothStateMessage: String = "Aguardando Bluetooth..."
    @Published var navigateToDetail = false
    private let scanUseCase: ScanForDevicesUseCase
    private var cancellables = Set<AnyCancellable>()
    let connectUseCase: ConnectToDeviceUseCase
    
    init(injector: DependencyInjector) {
        self.scanUseCase = injector.makeScanForDevicesUseCase()
        self.connectUseCase = injector.makeConnectToDeviceUseCase()
        
        setupBindings()
    }
    
    private func setupBindings() {
        scanUseCase.statePublisher()
            .map {
                state -> String in
                    switch state {
                        case .poweredOn: return "Bluetooth Ligado"
                        case .poweredOff: return "Bluetooth Desligado"
                        case .unauthorized: return "Bluetooth Não Autorizado"
                        default: return "Aguardando Bluetooth..."
                    }
            }
            .assign(to: &$bluetoothStateMessage)

        connectUseCase.getConnectedDevicePublisher()
            .sink { [weak self] device in
                self?.selectedDevice = device
                self?.navigateToDetail = (device != nil)
            }
            .store(in: &cancellables)
    }
    
    func toggleScan() {
        isScanning ? stopScan() : startScan()
    }
    
    private func startScan() {
        isScanning = true
        devices.removeAll()

        scanUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$devices)
    }
    
    func stopScan() {
        isScanning = false
        scanUseCase.stop()
    }
    
    func connect(to device: Device) {
        stopScan()
        connectUseCase.execute(device: device)
    }
}
