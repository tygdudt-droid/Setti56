import SwiftUI

struct NetworkRow: View {
    enum State { case idle, connected, joining }
    let network: MockWiFiNetwork
    let state: State
    var onTap: () -> Void

    @SwiftUI.State private var showDetail = false

    var body: some View {
        HStack(spacing: 12) {
            Group {
                switch state {
                case .connected: Image(systemName: "checkmark").font(.body.weight(.semibold)).foregroundStyle(.tint)
                case .joining: ProgressView().controlSize(.small)
                case .idle: Color.clear
                }
            }
            .frame(width: 20)
            Text(network.ssid)
            Spacer()
            HStack(spacing: 10) {
                if network.security.isSecured { Image(systemName: "lock.fill") }
                Image(systemName: network.isHotspot ? "personalhotspot" : "wifi", variableValue: Double(network.signal) / 3)
                Button { showDetail = true } label: { Image(systemName: "info.circle").font(.title3) }
                    .buttonStyle(.borderless)
            }
            .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { if state == .idle { onTap() } }
        .navigationDestination(isPresented: $showDetail) { NetworkDetailView(network: network) }
    }
}
