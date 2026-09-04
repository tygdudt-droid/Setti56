import SwiftUI

struct BatteryHealthView: View {
    let data: BatteryDataProvider
    var body: some View {
        List {
            Section {
                LabeledContent("Maximum Capacity", value: "\(data.maximumCapacity)%")
            } footer: {
                Text("This is a measure of battery capacity relative to when it was new. Lower capacity may result in fewer hours of usage between charges.")
            }
            Section {
                LabeledContent("Cycle Count", value: "\(data.cycleCount)")
                LabeledContent("Manufacture Date", value: Date.daysAgo(410).formatted(.dateTime.month(.wide).year()))
                LabeledContent("First Use", value: Date.daysAgo(380).formatted(.dateTime.month(.wide).year()))
            } footer: {
                Text("Your battery is currently supporting normal peak performance.")
            }
            Section {
                Link("About Battery & Performance…", destination: URL(string: "https://support.apple.com/en-us/HT208387")!)
            }
        }
        .navigationTitle("Battery Health")
        .navigationBarTitleDisplayMode(.inline)
    }
}
