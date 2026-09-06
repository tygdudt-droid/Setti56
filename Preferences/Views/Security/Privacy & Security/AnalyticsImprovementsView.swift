import SwiftUI

/// Settings > Privacy & Security > Analytics & Improvements
/// iOS 26 layout: the first card hosts the main toggle and the Analytics Data
/// row together; every other toggle sits in its own card with its footer below.
struct AnalyticsImprovementsView: View {
    @AppStorage("analytics.share") private var share = true
    @AppStorage("analytics.icloud") private var icloud = true
    @AppStorage("analytics.developers") private var developers = true
    @AppStorage("analytics.health") private var health = true
    @AppStorage("analytics.siri") private var siri = true
    @AppStorage("analytics.assistive") private var assistive = true

    private var deviceName: String { MockDevice.current.deviceTypeName }

    var body: some View {
        List {
            // MARK: Share [Device] Analytics + Analytics Data (one card)
            Section {
                Toggle("Share \(deviceName) Analytics", isOn: $share)
                SLink("Analytics Data") {
                    AnalyticsDataView()
                }
            } footer: {
                Text("Help Apple improve its products and services by automatically sending daily diagnostic and usage data. Data may include location information. Analytics uses wireless data. [About Analytics & Privacy…](https://www.apple.com/legal/privacy/data/)")
            }

            // MARK: Share iCloud Analytics
            Section {
                Toggle("Share iCloud Analytics", isOn: $icloud)
            } footer: {
                Text("Help Apple improve its products and services, including Siri and other intelligent features, by allowing analytics of usage and data from your iCloud account. [About iCloud Analytics & Privacy…](https://www.apple.com/legal/privacy/data/)")
            }

            // MARK: Share With App Developers
            Section {
                Toggle("Share With App Developers", isOn: $developers)
            } footer: {
                Text("Help app developers improve their apps by allowing Apple to share crash data as well as statistics about how you use their apps with them. [About App Analytics & Privacy...](https://www.apple.com/legal/privacy/data/)")
            }

            // MARK: Improve Health & Activity
            Section {
                Toggle("Improve Health & Activity", isOn: $health)
            } footer: {
                Text("Help Apple improve health and fitness features by sharing your activity, workout, and health-related data such as physical activity levels, approximate location, heart-related measurements, or ECG classifications. This also enables sharing data from your other devices. [About Improve Health and Activity & Privacy...](https://www.apple.com/legal/privacy/data/)")
            }

            // MARK: Improve Siri & Dictation
            Section {
                Toggle("Improve Siri & Dictation", isOn: $siri)
            } footer: {
                Text("Help Apple improve Siri and Dictation by sharing the audio recordings and transcripts of your interactions with Siri, Dictation, and Translate from this device. [About Improve Siri and Dictation & Privacy...](https://www.apple.com/legal/privacy/data/)")
            }

            // MARK: Improve Assistive Voice Features
            Section {
                Toggle("Improve Assistive Voice Features", isOn: $assistive)
            } footer: {
                Text("Help Apple improve Vocal Shortcuts and Voice Control by sharing audio recordings of your Vocal Shortcuts and Voice Control interactions from this device. [About Improve Assistive Voice Features & Privacy...](https://www.apple.com/legal/privacy/data/)")
            }
        }
        .navigationTitle("Analytics & Improvements")
        .settingsReadableWidth()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AnalyticsImprovementsView()
    }
}
