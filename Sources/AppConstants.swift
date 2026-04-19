import Foundation

enum AppConstants {
    static let websiteDisplayText = "www.softviser.com.tr"
    static let githubDisplayText = "softviser/VPNKeepAwake"

    static let websiteURL = URL(string: "https://www.softviser.com.tr")
    static let githubURL = URL(string: "https://github.com/softviser/VPNKeepAwake")

    static var shortVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
