//
//  AboutView.swift
//  Preferences
//
//  Settings > General > About — public API only, cannot crash.
//

import SwiftUI

/// View for Settings > General > About
struct AboutView: View {
    @AppStorage("DeviceName") private var storedDeviceName = UIDevice.current.name
    @State private var showingRegulatoryModel = false
    @State private var availableStorage = "…"
    @State private var showMockConfig = false
    private let device = MockDevice.current
    private let identity = MockDeviceIdentity.stored
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var body: some View {
        CustomList(title: "About", topPadding: true) {
            // MARK: Name + Device identity (one card)
            Section {
                NavigationLink {
                    NameView()
                } label: {
                    LabeledContent("Name", value: storedDeviceName)
                }
                NavigationLink {
                    ControllerBridgeView(
                        "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/GeneralSettingsUI",
                        controller: "PSGSoftwareVersionController",
                        title: "\(device.systemName) Version"
                    )
                } label: {
                    LabeledContent("\(device.systemName) Version", value: DeviceProfile.osVersion)
                }
                LabeledContent("Model Name", value: DeviceProfile.modelName)
                    .textSelection(.enabled)
                LabeledContent("Model Number", value: showingRegulatoryModel ? identity.regulatoryModel : identity.modelNumber)
                    .textSelection(.enabled)
                    .contentShape(Rectangle())
                    .onTapGesture { showingRegulatoryModel.toggle() }
                LabeledContent("Serial Number", value: identity.serialNumber)
                    .textSelection(.enabled)
                    .contextMenu {
                        Button("Copy", systemImage: "doc.on.doc") {
                            UIPasteboard.general.string = identity.serialNumber
                        }
                        Button("Mock Configuration…", systemImage: "wrench.and.screwdriver") {
                            showMockConfig = true
                        }
                    }
            }

            // MARK: Coverage
            Section {
                NavigationLink {
                    AppleCareWarrantyView()
                } label: {
                    Text("Coverage Expired")
                }
            }

            // MARK: Content & capacity
            Section {
                LabeledContent("Songs", value: "0")
                LabeledContent("Videos", value: "357")
                LabeledContent("Photos", value: "2,126")
                LabeledContent("Applications", value: "\(MockAppCatalog.all.count)")
                LabeledContent("Capacity", value: identity.capacity ?? "256 GB")
                LabeledContent("Available", value: identity.available ?? availableStorage)
            }

            // MARK: Network addresses
            Section {
                LabeledContent("Wi-Fi Address", value: identity.wifiAddress)
                    .textSelection(.enabled)
                LabeledContent("Bluetooth", value: identity.bluetoothAddress)
                    .textSelection(.enabled)
                NavigationLink("SEID") {
                    SEIDView()
                }
            }

            // MARK: Cellular identifiers (cellular devices only)
            if UIDevice.CellularTelephonyCapability {
                Section {
                    LabeledContent("Modem Firmware", value: identity.modemFirmware)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EID")
                        Text(identity.eid)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                            .textSelection(.enabled)
                    }
                    LabeledContent("IMSI", value: "—")
                    LabeledContent("IMEI", value: identity.imei)
                        .textSelection(.enabled)
                }
            }

            // MARK: Certificate trust
            Section {
                NavigationLink("Certificate Trust Settings") {
                    ControllerBridgeView(
                        "/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/GeneralSettingsUI",
                        controller: "PSGCertTrustSettings",
                        title: "Certificate Trust Settings"
                    )
                }
            }
        }
        .task {
            availableStorage = getAvailableStorage() ?? "—"
        }
        .navigationDestination(isPresented: $showMockConfig) {
            MockConfigView()
        }
    }

    private func getAvailableStorage() -> String? {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let freeSize = attributes[.systemFreeSize] as? NSNumber else {
            return nil
        }
        return ByteCountFormatter.string(fromByteCount: freeSize.int64Value, countStyle: .file)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
