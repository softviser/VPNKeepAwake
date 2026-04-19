import Foundation
import SwiftUI

// MARK: - Localization Manager
enum Language: String, CaseIterable {
    case turkish = "tr"
    case english = "en"

    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }
    private let lock = NSLock()

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"
        self.currentLanguage = Language(rawValue: saved) ?? .turkish
    }

    func setLanguage(_ language: Language) {
        lock.lock()
        defer { lock.unlock() }
        DispatchQueue.main.async {
            self.currentLanguage = language
        }
    }

    // MARK: - Translations
    var appTitle: String {
        currentLanguage == .turkish ? "VPN Keep Awake" : "VPN Keep Awake"
    }

    var vpnStatus: String {
        currentLanguage == .turkish ? "VPN Durumu" : "VPN Status"
    }

    var connected: String {
        currentLanguage == .turkish ? "Bağlı" : "Connected"
    }

    var notConnected: String {
        currentLanguage == .turkish ? "Bağlı Değil" : "Not Connected"
    }

    var sleepProtection: String {
        currentLanguage == .turkish ? "Uyku Koruması" : "Sleep Protection"
    }

    var active: String {
        currentLanguage == .turkish ? "Aktif" : "Active"
    }

    var waiting: String {
        currentLanguage == .turkish ? "Bekleniyor" : "Waiting"
    }

    var disabled: String {
        currentLanguage == .turkish ? "Kapalı" : "Disabled"
    }

    var networkTraffic: String {
        currentLanguage == .turkish ? "Ağ Trafiği" : "Network Traffic"
    }

    var download: String {
        currentLanguage == .turkish ? "İndirme" : "Download"
    }

    var upload: String {
        currentLanguage == .turkish ? "Yükleme" : "Upload"
    }

    var total: String {
        currentLanguage == .turkish ? "Toplam" : "Total"
    }

    var todayStats: String {
        currentLanguage == .turkish ? "Bugünkü İstatistikler" : "Today's Statistics"
    }

    var connections: String {
        currentLanguage == .turkish ? "Bağlantı" : "Connections"
    }

    var disconnections: String {
        currentLanguage == .turkish ? "Kopma" : "Disconnects"
    }

    var settings: String {
        currentLanguage == .turkish ? "Ayarlar" : "Settings"
    }

    var checkInterval: String {
        currentLanguage == .turkish ? "Kontrol Aralığı" : "Check Interval"
    }

    var notifications: String {
        currentLanguage == .turkish ? "Bildirimler" : "Notifications"
    }

    var showNotifications: String {
        currentLanguage == .turkish ? "Bildirimleri Göster" : "Show Notifications"
    }

    var soundAlert: String {
        currentLanguage == .turkish ? "Sesli Uyarı" : "Sound Alert"
    }

    var language: String {
        currentLanguage == .turkish ? "Dil" : "Language"
    }

    var logFile: String {
        currentLanguage == .turkish ? "Log Dosyası" : "Log File"
    }

    var openInFinder: String {
        currentLanguage == .turkish ? "Finder'da Aç" : "Open in Finder"
    }

    var quit: String {
        currentLanguage == .turkish ? "Çıkış" : "Quit"
    }

    var vpnNotConnected: String {
        currentLanguage == .turkish ? "VPN bağlı değil" : "VPN not connected"
    }

    var autoRefresh: String {
        currentLanguage == .turkish ? "Otomatik yenileme" : "Auto refresh"
    }

    var nextUpdate: String {
        currentLanguage == .turkish ? "Sonraki güncelleme" : "Next update"
    }

    var seconds: String {
        currentLanguage == .turkish ? "sn" : "sec"
    }

    var hours: String {
        currentLanguage == .turkish ? "saat" : "hours"
    }

    var minutes: String {
        currentLanguage == .turkish ? "dk" : "min"
    }

    var protectedFor: String {
        currentLanguage == .turkish ? "korunuyor" : "protected"
    }

    // Notification texts
    var vpnConnectedTitle: String {
        currentLanguage == .turkish ? "VPN Bağlandı" : "VPN Connected"
    }

    var vpnConnectedBody: String {
        currentLanguage == .turkish ? "Uyku koruması aktif." : "Sleep protection active."
    }

    var vpnDisconnectedTitle: String {
        currentLanguage == .turkish ? "VPN Kesildi!" : "VPN Disconnected!"
    }

    var vpnDisconnectedBody: String {
        currentLanguage == .turkish ? "Dikkat: Uyku koruması devre dışı!" : "Warning: Sleep protection disabled!"
    }

    // About section
    var about: String {
        currentLanguage == .turkish ? "Hakkında" : "About"
    }

    var version: String {
        currentLanguage == .turkish ? "Sürüm" : "Version"
    }

    var developer: String {
        currentLanguage == .turkish ? "Geliştirici" : "Developer"
    }

    var website: String {
        currentLanguage == .turkish ? "Web Sitesi" : "Website"
    }

    var openSource: String {
        currentLanguage == .turkish ? "Açık Kaynak" : "Open Source"
    }

    var license: String {
        currentLanguage == .turkish ? "Lisans" : "License"
    }

    var madeWith: String {
        currentLanguage == .turkish ? "Swift ile geliştirildi" : "Built with Swift"
    }

    var freeAndOpenSource: String {
        currentLanguage == .turkish ? "Ücretsiz ve Açık Kaynak" : "Free and Open Source"
    }

    // Accessibility permission
    var accessibilityRequired: String {
        currentLanguage == .turkish ? "Erişilebilirlik İzni Gerekli" : "Accessibility Permission Required"
    }

    var accessibilityDescription: String {
        currentLanguage == .turkish
            ? "Uyku engellemesinin tam çalışması için Erişilebilirlik izni gereklidir."
            : "Accessibility permission is required for full sleep prevention."
    }

    var openSystemSettings: String {
        currentLanguage == .turkish ? "Sistem Ayarlarını Aç" : "Open System Settings"
    }

    var accessibilityGranted: String {
        currentLanguage == .turkish ? "Erişilebilirlik izni verildi" : "Accessibility permission granted"
    }

    // Quit confirmation
    var quitConfirmTitle: String {
        currentLanguage == .turkish ? "Uygulamayı Kapat" : "Quit Application"
    }

    var quitConfirmMessage: String {
        currentLanguage == .turkish
            ? "Program kapatılacaktır. Arka plana atmak için X butonunu tıklayın."
            : "The application will be closed. Click the X button to minimize to background."
    }

    var quitConfirmButton: String {
        currentLanguage == .turkish ? "Kapat" : "Quit"
    }

    var cancelButton: String {
        currentLanguage == .turkish ? "İptal" : "Cancel"
    }

    var showUptimeInMenuBar: String {
        currentLanguage == .turkish ? "Menü Bar'da Uptime Göster" : "Show Uptime in Menu Bar"
    }

    var vpnInterfaces: String {
        currentLanguage == .turkish ? "VPN Bağlantıları" : "VPN Connections"
    }

    var launchAtLogin: String {
        currentLanguage == .turkish ? "Başlangıçta Otomatik Aç" : "Launch at Login"
    }

    var launchAtLoginNote: String {
        currentLanguage == .turkish
            ? "macOS açıldığında uygulama otomatik başlar"
            : "App starts automatically when macOS boots"
    }
}
