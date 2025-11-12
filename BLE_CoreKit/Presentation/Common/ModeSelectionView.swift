import SwiftUI

struct ModeSelectionView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {

                VStack {
                    Text("Bem-vindo ao")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text("BLE Core Kit")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            .linearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, 20)
                .padding(.bottom, 10)

                NavigationLink(destination: DeviceListView(
                    viewModel: DeviceListViewModel(
                        injector: DependencyInjector.shared
                    )
                )) {
                    ModeCardView(
                        title: "Modo Central",
                        subtitle: "Scanner de Dispositivos",
                        iconName: "magnifyingglass.circle.fill",
                        gradient: LinearGradient(
                            colors: [Color(red: 0.1, green: 0.4, blue: 0.9), .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }

                NavigationLink(destination: PeripheralView(
                    viewModel: PeripheralViewModel(
                        injector: DependencyInjector.shared
                    )
                )) {
                    ModeCardView(
                        title: "Modo Periférico",
                        subtitle: "Simulador de Dispositivo",
                        iconName: "antenna.radiowaves.left.and.right.circle.fill",
                        gradient: LinearGradient(
                            colors: [.teal, Color(red: 0.1, green: 0.6, blue: 0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Menu")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}
