import SwiftUI

struct AnalyticsImprovementsView: View {
    @AppStorage("analytics.share") private var share = true
    @AppStorage("analytics.icloud") private var icloud = false
    @AppStorage("analytics.siri") private var siri = false
    @AppStorage("analytics.safety") private var safety = true
    @AppStorage("analytics.assistive") private var assistive = false
    @AppStorage("analytics.developers") private var developers = true

    var body: some View {
        List {
            Section {
                Toggle("Share \(MockDevice.current.deviceTypeName) Analytics", isOn: $share)
            } footer: {
                Text("Help Apple improve its products and services by automatically sending daily diagnostic and usage data. Data may include location information. Analytics uses wireless data. [About Analytics & Privacy…](https://www.apple.com/privacy)")
            }
            Section {
                NavigationLink("Analytics Data") { AnalyticsDataView() }
            }
            Section { Toggle("Share iCloud Analytics", isOn: $icloud) } footer: {
                Text("Help Apple improve Siri and other intelligent features by analyzing how you use iCloud data from your account.")
            }
            Section { Toggle("Improve Siri & Dictation", isOn: $siri) } footer: {
                Text("Help improve Siri and Dictation by allowing Apple to store and review audio of your Siri and Dictation interactions.")
            }
            Section { Toggle("Improve Safety", isOn: $safety) } footer: {
                Text("Help improve safety features by sharing data about crash detection and emergency calls.")
            }
            Section { Toggle("Improve Assistive Voice Features", isOn: $assistive) }
            Section { Toggle("Share with App Developers", isOn: $developers) } footer: {
                Text("Help app developers improve their apps by allowing Apple to share crash data and statistics on how you use their apps.")
            }
        }
        .navigationTitle("Analytics & Improvements")
        .navigationBarTitleDisplayMode(.inline)
    }
}
