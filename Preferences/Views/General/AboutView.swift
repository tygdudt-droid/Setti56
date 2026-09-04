import SwiftUI

/// iOS 26 "About" – public API only, cannot crash.
struct AboutView: View {
    @AppStorage("device.name") private var name = UIDevice.current.name
    @State private var showRegulatoryModel = false
    private let device = MockDevice.current
    private let identity = MockDeviceIdentity.stored

    var body: some View {
        List {
            Section {
                NavigationLink { DeviceNameView(name: $name) } label: {
                    LabeledContent("Name", value: name)
                }
            }

            Section {
                NavigationLink { IOSVersionView() } label: {
                    LabeledContent("\(device.systemName) Version", value: device.systemVersion)
                }
                LabeledContent("Model Name", value: device.modelName)
                LabeledContent("Model Number", value: showRegulatoryModel ? identity.regulatoryModel : identity.modelNumber)
                    .contentShape(Rectangle())
                    .onTapGesture { showRegulatoryModel.toggle() }
                LabeledContent("Serial Number", value: identity.serialNumber)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.serialNumber } }
                NavigationLink { CoverageView() } label: {
                    LabeledContent("Coverage", value: "Limited Warranty")
                }
            }

            Section {
                LabeledContent("Songs", value: "0")
                LabeledContent("Videos", value: "12")
                LabeledContent("Photos", value: "3,482")
                LabeledContent("Applications", value: "\(MockAppCatalog.all.count)")
                LabeledContent("Capacity", value: "256 GB")
                LabeledContent("Available", value: "118.42 GB")
            }

            Section {
                LabeledContent("Wi-Fi Address", value: identity.wifiAddress)
                LabeledContent("Bluetooth", value: identity.bluetoothAddress)
                LabeledContent("Modem Firmware", value: identity.modemFirmware)
                LabeledContent("SEID", value: String(identity.seid.prefix(8)) + "…")
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.seid } }
                LabeledContent("EID", value: identity.eid)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.eid } }
                LabeledContent("Carrier Lock", value: "No SIM restrictions")
            }

            if device.isPhone {
                Section("Available SIMs") {
                    NavigationLink { SIMDetailView(identity: identity) } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Primary")
                            Text("No SIM").font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                NavigationLink("Certificate Trust Settings") { CertificateTrustView() }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeviceNameView: View {
    @Binding var name: String
    @FocusState private var focused: Bool
    var body: some View {
        List {
            HStack {
                TextField("Name", text: $name).focused($focused)
                if !name.isEmpty {
                    Button { name = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary) }
                        .buttonStyle(.borderless)
                }
            }
        }
        .navigationTitle("Name")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
    }
}

struct IOSVersionView: View {
    private let d = MockDevice.current
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(d.systemName) \(d.systemVersion)").font(.headline)
                    Text("Build \(d.buildNumber)").font(.footnote).foregroundStyle(.secondary)
                }
            } footer: {
                Text("\(d.systemName) \(d.systemVersion) brings a beautiful new design with Liquid Glass, more expressive experiences across your apps, and intelligent features that make everyday tasks easier.")
            }
        }
        .navigationTitle("\(d.systemName) Version")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CoverageView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Limited Warranty", value: "Active")
                LabeledContent("Expires", value: Date.now.addingTimeInterval(200 * 86_400).formatted(date: .abbreviated, time: .omitted))
            } footer: {
                Text("Your device is covered by Apple’s Limited Warranty for hardware repairs and service.")
            }
            Section {
                Link("Learn About AppleCare+", destination: URL(string: "https://www.apple.com/support/products/")!)
            }
        }
        .navigationTitle("Coverage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SIMDetailView: View {
    let identity: MockDeviceIdentity
    var body: some View {
        List {
            Section {
                LabeledContent("Network", value: "—")
                LabeledContent("Carrier", value: "—")
                LabeledContent("IMEI", value: identity.imei)
                    .contextMenu { Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = identity.imei } }
                LabeledContent("IMEI2", value: identity.imei2)
                LabeledContent("ICCID", value: identity.iccid)
            }
        }
        .navigationTitle("Primary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CertificateTrustView: View {
    @State private var fullTrust = false
    var body: some View {
        List {
            Section {
                LabeledContent("Trust Store Version", value: "2025071100")
                LabeledContent("Trust Asset Version", value: "80")
            }
            Section {
                Toggle("Enable Full Trust for Root Certificates", isOn: $fullTrust)
            } footer: {
                Text("No certificates have been installed on this device.")
            }
        }
        .navigationTitle("Certificate Trust Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
