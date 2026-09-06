import SwiftUI

/// Settings > Battery > Battery Health (iPadOS 26): one card per value with
/// an explanatory footer under each.
struct BatteryHealthView: View {
    let data: BatteryDataProvider
    @Environment(SettingsStore.self) private var store

    private var deviceName: String { MockDevice.current.deviceTypeName }

    var body: some View {
        CustomList(title: "Battery Health", topPadding: true) {
            Section {
                LabeledContent("Battery Health") {
                    Text(data.healthStatus).foregroundStyle(.secondary)
                }
            } footer: {
                Text("This \(deviceName) battery is performing as expected. [About Battery & Warranty...](https://support.apple.com/battery-service)")
            }

            Section {
                LabeledContent("Maximum Capacity") {
                    Text("\(data.maximumCapacity)%").foregroundStyle(.secondary)
                }
            } footer: {
                Text("This is a measure of battery capacity relative to when it was new. Lower capacity may result in fewer hours of usage between charges.")
            }

            Section {
                LabeledContent("Cycle Count") {
                    Text("\(data.cycleCount)").foregroundStyle(.secondary)
                }
            } footer: {
                Text("This is the number of times \(deviceName) has used your battery’s capacity. [Learn more...](https://support.apple.com/HT212612)")
            }

            Section {
                Toggle("80% Limit", isOn: Binding(
                    get: { store.chargeLimit == 80 },
                    set: { store.chargeLimit = $0 ? 80 : 100 }
                ))
            } footer: {
                Text("Your \(deviceName) will only charge to about 80%. Charge limit will return to 80% at 06:00. [Learn more...](https://support.apple.com/HT210512)")
            }

            Section {
                LabeledContent("Manufacture Date") {
                    Text(data.manufactureDate).foregroundStyle(.secondary)
                }
                LabeledContent("First Use") {
                    Text(data.firstUse).foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BatteryHealthView(data: BatteryDataProvider.shared)
    }
    .environment(SettingsStore.shared)
    .environment(PrimarySettingsListModel())
}
