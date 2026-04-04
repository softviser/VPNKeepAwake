//
//  VPN Keep Awake
//  macOS menu bar app — prevents sleep while VPN is active
//
//  Copyright (c) 2026 Softviser — www.softviser.com.tr
//  Licensed under the MIT License. See LICENSE file for details.
//

import Cocoa
import SwiftUI
import IOKit.pwr_mgt
import SystemConfiguration
import UserNotifications
import AudioToolbox
import ServiceManagement

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

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "tr"
        self.currentLanguage = Language(rawValue: saved) ?? .turkish
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

// MARK: - Statistics Manager
class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()

    @Published var vpnConnectedSince: Date?
    @Published var sleepPreventedSince: Date?
    @Published var todayConnectionCount: Int = 0
    @Published var todayDisconnectionCount: Int = 0
    private var currentDay: Int = 0

    private init() {
        currentDay = Calendar.current.component(.day, from: Date())
    }

    func vpnConnected() {
        DispatchQueue.main.async {
            self.checkDayChange()
            if self.vpnConnectedSince == nil {
                self.vpnConnectedSince = Date()
                self.todayConnectionCount += 1

            }
        }
    }

    func vpnDisconnected() {
        DispatchQueue.main.async {
            self.checkDayChange()
            if self.vpnConnectedSince != nil {
                self.vpnConnectedSince = nil
                self.todayDisconnectionCount += 1

            }
        }
    }

    func sleepPreventionStarted() {
        DispatchQueue.main.async {
            if self.sleepPreventedSince == nil {
                self.sleepPreventedSince = Date()
            }
        }
    }

    func sleepPreventionStopped() {
        DispatchQueue.main.async {
            self.sleepPreventedSince = nil
        }
    }

    private func checkDayChange() {
        let today = Calendar.current.component(.day, from: Date())
        if today != currentDay {
            currentDay = today
            todayConnectionCount = 0
            todayDisconnectionCount = 0
        }
    }

    var vpnUptime: TimeInterval? {
        guard let since = vpnConnectedSince else { return nil }
        return Date().timeIntervalSince(since)
    }

    var sleepPreventionDuration: TimeInterval? {
        guard let since = sleepPreventedSince else { return nil }
        return Date().timeIntervalSince(since)
    }

    static func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    func formatDurationLong(_ interval: TimeInterval) -> String {
        let l = LocalizationManager.shared
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60

        if hours > 0 {
            return "\(hours) \(l.hours) \(minutes) \(l.minutes)"
        } else if minutes > 0 {
            return "\(minutes) \(l.minutes)"
        } else {
            return "< 1 \(l.minutes)"
        }
    }
}

// MARK: - Logger
class LogManager {
    static let shared = LogManager()
    private let logFile: URL
    private let dateFormatter: DateFormatter

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("VPNKeepAwake")
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        logFile = appFolder.appendingPathComponent("vpn_log.txt")
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    func log(_ message: String, type: String = "INFO") {
        let timestamp = dateFormatter.string(from: Date())
        let logLine = "[\(timestamp)] [\(type)] \(message)\n"
        if let data = logLine.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFile.path) {
                if let handle = try? FileHandle(forWritingTo: logFile) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: logFile)
            }
        }
    }

    var logFilePath: String { logFile.path }
}

// MARK: - Settings Manager
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard

    @Published var checkInterval: TimeInterval {
        didSet { defaults.set(checkInterval, forKey: "checkInterval") }
    }
    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: "soundEnabled") }
    }
    @Published var notificationsEnabled: Bool {
        didSet { defaults.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }
    @Published var showUptimeInMenuBar: Bool {
        didSet { defaults.set(showUptimeInMenuBar, forKey: "showUptimeInMenuBar") }
    }

    private init() {
        let interval = defaults.double(forKey: "checkInterval")
        self.checkInterval = interval > 0 ? interval : 10.0
        self.soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        self.notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.showUptimeInMenuBar = defaults.object(forKey: "showUptimeInMenuBar") as? Bool ?? true
    }
}

// MARK: - Notification Manager
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                LogManager.shared.log("Notification auth error: \(error.localizedDescription)", type: "ERROR")
            }
            LogManager.shared.log("Notification permission: \(granted ? "granted" : "denied")", type: "PERM")
        }
    }

    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(macOS 12.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    func sendNotification(title: String, body: String, playSound: Bool = true) {
        guard SettingsManager.shared.notificationsEnabled else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if playSound && SettingsManager.shared.soundEnabled { content.sound = .default }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                LogManager.shared.log("Notification send error: \(error.localizedDescription)", type: "ERROR")
            }
        }
        if playSound && SettingsManager.shared.soundEnabled {
            AudioServicesPlaySystemSound(SystemSoundID(1005))
        }
    }
}

// MARK: - Network Statistics (Fixed)
class NetworkStatsManager: ObservableObject {
    @Published var downloadSpeed: Double = 0
    @Published var uploadSpeed: Double = 0
    @Published var totalDownload: UInt64 = 0
    @Published var totalUpload: UInt64 = 0
    @Published var sessionDownload: UInt64 = 0
    @Published var sessionUpload: UInt64 = 0

    private var lastBytesIn: UInt64 = 0
    private var lastBytesOut: UInt64 = 0
    private var lastCheckTime: Date?
    private var sessionStartBytesIn: UInt64 = 0
    private var sessionStartBytesOut: UInt64 = 0
    private var isFirstReading = true

    func update(for interfaceName: String) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return }
        defer { freeifaddrs(ifaddr) }

        var ptr = firstAddr
        while true {
            let name = String(cString: ptr.pointee.ifa_name)

            // Find link-level data for interface
            if name == interfaceName && ptr.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                if let data = ptr.pointee.ifa_data {
                    let networkData = data.assumingMemoryBound(to: if_data.self).pointee
                    let bytesIn = UInt64(networkData.ifi_ibytes)
                    let bytesOut = UInt64(networkData.ifi_obytes)

                    let now = Date()

                    // Store initial values on first read
                    if isFirstReading {
                        sessionStartBytesIn = bytesIn
                        sessionStartBytesOut = bytesOut
                        lastBytesIn = bytesIn
                        lastBytesOut = bytesOut
                        lastCheckTime = now
                        isFirstReading = false
                        return
                    }

                    guard let lastTime = lastCheckTime else {
                        lastBytesIn = bytesIn
                        lastBytesOut = bytesOut
                        lastCheckTime = now
                        return
                    }

                    let elapsed = now.timeIntervalSince(lastTime)

                    // Need at least 0.5s elapsed
                    if elapsed >= 0.5 {
                        // Calculate speed (only on increase)
                        let deltaIn = bytesIn >= lastBytesIn ? bytesIn - lastBytesIn : 0
                        let deltaOut = bytesOut >= lastBytesOut ? bytesOut - lastBytesOut : 0

                        let newDownloadSpeed = Double(deltaIn) / elapsed
                        let newUploadSpeed = Double(deltaOut) / elapsed

                        // Session totals
                        let sessDown = bytesIn >= sessionStartBytesIn ? bytesIn - sessionStartBytesIn : 0
                        let sessUp = bytesOut >= sessionStartBytesOut ? bytesOut - sessionStartBytesOut : 0

                        DispatchQueue.main.async {
                            self.downloadSpeed = newDownloadSpeed
                            self.uploadSpeed = newUploadSpeed
                            self.totalDownload = bytesIn
                            self.totalUpload = bytesOut
                            self.sessionDownload = sessDown
                            self.sessionUpload = sessUp
                        }

                        lastBytesIn = bytesIn
                        lastBytesOut = bytesOut
                        lastCheckTime = now
                    }
                    return
                }
            }

            guard let next = ptr.pointee.ifa_next else { break }
            ptr = next
        }
    }

    func reset() {
        DispatchQueue.main.async {
            self.downloadSpeed = 0
            self.uploadSpeed = 0
            self.sessionDownload = 0
            self.sessionUpload = 0
        }
        isFirstReading = true
        lastCheckTime = nil
    }

    func formatSpeed(_ bps: Double) -> String {
        if bps < 1024 {
            return String(format: "%.0f B/s", bps)
        } else if bps < 1024 * 1024 {
            return String(format: "%.1f KB/s", bps / 1024)
        } else {
            return String(format: "%.2f MB/s", bps / (1024 * 1024))
        }
    }

    func formatBytes(_ bytes: UInt64) -> String {
        if bytes < 1024 {
            return "\(bytes) B"
        } else if bytes < 1024 * 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        } else if bytes < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", Double(bytes) / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", Double(bytes) / (1024 * 1024 * 1024))
        }
    }
}

// MARK: - Sleep Manager
class SleepManager: ObservableObject {
    @Published var isPreventingSleep = false
    @Published var hasAccessibilityPermission = false
    private var assertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0
    private var activityTimer: Timer?

    func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrusted()
        if trusted != hasAccessibilityPermission {
            if trusted {
                LogManager.shared.log("Accessibility permission granted", type: "PERM")
            }
            hasAccessibilityPermission = trusted
        }
    }

    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    func preventSleep() -> Bool {
        guard !isPreventingSleep else { return true }

        let reason = "VPN connection active" as CFString

        // Sistem uyku + display assertion
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &displayAssertionID
        )

        if result == kIOReturnSuccess {
            DispatchQueue.main.async { self.isPreventingSleep = true }
            StatisticsManager.shared.sleepPreventionStarted()
            LogManager.shared.log("Sleep prevented", type: "SLEEP")

            if displayResult != kIOReturnSuccess {
                LogManager.shared.log("Display assertion failed", type: "SLEEP")
            }

            startActivitySimulation()
            return true
        }
        return false
    }

    func allowSleep() {
        guard isPreventingSleep else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0

        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }

        stopActivitySimulation()

        DispatchQueue.main.async { self.isPreventingSleep = false }
        StatisticsManager.shared.sleepPreventionStopped()
        LogManager.shared.log("Sleep allowed", type: "SLEEP")
    }

    // MARK: - Activity Simulation

    private func startActivitySimulation() {
        stopActivitySimulation()
        activityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.simulateActivity()
        }
    }

    private func stopActivitySimulation() {
        activityTimer?.invalidate()
        activityTimer = nil
    }

    private func simulateActivity() {
        // IOKit user activity
        IOPMAssertionDeclareUserActivity(
            "VPN Keep Awake - activity" as CFString,
            kIOPMUserActiveLocal,
            &assertionID
        )

        // Fare mikro hareketi (accessibility izni gerekli)
        guard hasAccessibilityPermission else { return }

        let currentPos = NSEvent.mouseLocation
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let cgPoint = CGPoint(x: currentPos.x, y: screenHeight - currentPos.y)

        if let moveEvent = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                                    mouseCursorPosition: CGPoint(x: cgPoint.x + 1, y: cgPoint.y), mouseButton: .left) {
            moveEvent.post(tap: .cghidEventTap)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let moveBack = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                                       mouseCursorPosition: cgPoint, mouseButton: .left) {
                moveBack.post(tap: .cghidEventTap)
            }
        }
    }
}

// MARK: - VPN Monitor
struct VPNInterface: Identifiable, Equatable {
    let id: String
    let name: String
    let ip: String

    static func == (lhs: VPNInterface, rhs: VPNInterface) -> Bool {
        lhs.id == rhs.id && lhs.ip == rhs.ip
    }
}

class VPNMonitor: ObservableObject {
    @Published var isConnected = false
    @Published var activeInterface: String = ""
    @Published var ipAddress: String = "-"
    @Published var allInterfaces: [VPNInterface] = []

    private let vpnPrefixes = ["ppp", "utun", "ipsec", "tun", "tap"]
    private var wasConnected = false
    let networkStats = NetworkStatsManager()

    func check() {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            updateState(interfaces: [])
            return
        }
        defer { freeifaddrs(ifaddr) }

        // Collect all VPN interfaces with an IPv4 address
        var found: [VPNInterface] = []

        var ptr = firstAddr
        while true {
            let name = String(cString: ptr.pointee.ifa_name)
            let flags = Int32(ptr.pointee.ifa_flags)
            let isUp = (flags & IFF_UP) != 0 && (flags & IFF_RUNNING) != 0

            if isUp, let addr = ptr.pointee.ifa_addr, addr.pointee.sa_family == UInt8(AF_INET) {
                for prefix in vpnPrefixes {
                    if name.hasPrefix(prefix) {
                        var sockAddr = addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        inet_ntop(AF_INET, &sockAddr.sin_addr, &hostname, socklen_t(NI_MAXHOST))
                        let ipStr = String(cString: hostname)

                        if !ipStr.isEmpty && ipStr != "0.0.0.0" {
                            found.append(VPNInterface(id: name, name: name, ip: ipStr))
                        }
                    }
                }
            }

            guard let next = ptr.pointee.ifa_next else { break }
            ptr = next
        }

        updateState(interfaces: found)

        if let primary = found.first {
            networkStats.update(for: primary.name)
        } else {
            networkStats.reset()
        }
    }

    private func updateState(interfaces: [VPNInterface]) {
        let connected = !interfaces.isEmpty
        let iface = interfaces.first?.name ?? ""
        let ip = interfaces.first?.ip ?? "-"

        DispatchQueue.main.async {
            self.isConnected = connected
            self.activeInterface = iface
            self.ipAddress = ip
            self.allInterfaces = interfaces
        }

        let l = LocalizationManager.shared

        if connected && !wasConnected {
            StatisticsManager.shared.vpnConnected()
            LogManager.shared.log("VPN connected: \(iface)", type: "VPN")
            NotificationManager.shared.sendNotification(
                title: l.vpnConnectedTitle,
                body: l.vpnConnectedBody
            )
        } else if !connected && wasConnected {
            StatisticsManager.shared.vpnDisconnected()
            LogManager.shared.log("VPN disconnected", type: "VPN")
            NotificationManager.shared.sendNotification(
                title: l.vpnDisconnectedTitle,
                body: l.vpnDisconnectedBody,
                playSound: true
            )
        }
        wasConnected = connected
    }
}

// MARK: - App State
class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isEnabled = true
    @Published var currentTime = Date()
    @Published var lastUpdateTime = Date()
    @Published var secondsUntilNextUpdate: Int = 10

    var vpnMonitor = VPNMonitor()
    var sleepManager = SleepManager()
    var stats = StatisticsManager.shared
    var settings = SettingsManager.shared
    var localization = LocalizationManager.shared

    private var checkTimer: Timer?
    private var uiTimer: Timer?
    private var countdownTimer: Timer?

    private init() {
        startMonitoring()
    }

    func startMonitoring() {
        checkTimer?.invalidate()
        uiTimer?.invalidate()
        countdownTimer?.invalidate()

        secondsUntilNextUpdate = Int(settings.checkInterval)

        checkTimer = Timer.scheduledTimer(withTimeInterval: settings.checkInterval, repeats: true) { [weak self] _ in
            self?.check()
            self?.secondsUntilNextUpdate = Int(self?.settings.checkInterval ?? 10)
        }

        uiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.currentTime = Date()
                self?.objectWillChange.send()
            }
        }

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                if let s = self, s.secondsUntilNextUpdate > 0 {
                    s.secondsUntilNextUpdate -= 1
                }
            }
        }

        check()
    }

    func check() {
        sleepManager.checkAccessibilityPermission()
        vpnMonitor.check()
        lastUpdateTime = Date()
        if vpnMonitor.isConnected && isEnabled {
            _ = sleepManager.preventSleep()
        } else {
            sleepManager.allowSleep()
        }
    }

    func toggle() {
        isEnabled.toggle()
        if !isEnabled { sleepManager.allowSleep() }
        check()
    }
}

// MARK: - SwiftUI Views

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            )
    }
}

struct StatusBadge: View {
    let isActive: Bool
    let activeText: String
    let inactiveText: String
    let activeColor: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isActive ? activeColor : .gray)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(isActive ? activeColor.opacity(0.5) : .clear, lineWidth: 2)
                        .scaleEffect(isActive ? 1.8 : 1)
                        .opacity(isActive ? 0 : 1)
                        .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: isActive)
                )

            Text(isActive ? activeText : inactiveText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isActive ? activeColor : .secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isActive ? activeColor.opacity(0.15) : Color.gray.opacity(0.1))
        )
    }
}

struct SpeedGauge: View {
    let label: String
    let speed: Double
    let icon: String
    let color: Color
    let formatter: (Double) -> String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(formatter(speed))
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AutoRefreshIndicator: View {
    let secondsRemaining: Int
    let totalSeconds: Int
    @ObservedObject var l = LocalizationManager.shared

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - secondsRemaining) / Double(totalSeconds)
    }

    var body: some View {
        HStack(spacing: 8) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                    .frame(width: 16, height: 16)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
            }

            Text("\(l.nextUpdate): \(secondsRemaining)\(l.seconds)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

struct DashboardView: View {
    @ObservedObject var state = AppState.shared
    @ObservedObject var l = LocalizationManager.shared
    @State private var showSettings = false
    @State private var showQuitAlert = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Title Bar
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text(l.appTitle)
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Button(action: { showSettings.toggle() }) {
                    Image(systemName: showSettings ? "xmark.circle.fill" : "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 20)

            ScrollView {
                VStack(spacing: 16) {
                    if showSettings {
                        settingsSection
                    } else {
                        mainSection
                    }
                }
                .padding(20)
            }

            Divider()

            // Footer with auto-refresh
            HStack {
                AutoRefreshIndicator(
                    secondsRemaining: state.secondsUntilNextUpdate,
                    totalSeconds: Int(state.settings.checkInterval)
                )

                Spacer()

                Button(action: { showQuitAlert = true }) {
                    Label(l.quit, systemImage: "power")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .frame(width: 380, height: 620)
        .alert(isPresented: $showQuitAlert) {
            Alert(
                title: Text(l.quitConfirmTitle),
                message: Text(l.quitConfirmMessage),
                primaryButton: .destructive(Text(l.quitConfirmButton)) {
                    NSApplication.shared.terminate(nil)
                },
                secondaryButton: .cancel(Text(l.cancelButton))
            )
        }
        .background(
            colorScheme == .dark
                ? Color(NSColor.windowBackgroundColor)
                : Color(NSColor.controlBackgroundColor)
        )
    }

    var mainSection: some View {
        VStack(spacing: 16) {
            // Accessibility permission warning
            if !state.sleepManager.hasAccessibilityPermission {
                GlassCard {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.orange)

                            Text(l.accessibilityRequired)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.orange)

                            Spacer()
                        }

                        Text(l.accessibilityDescription)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: {
                            state.sleepManager.requestAccessibilityPermission()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "gear")
                                    .font(.system(size: 12))
                                Text(l.openSystemSettings)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.15))
                            )
                            .foregroundColor(.orange)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // VPN Status
            GlassCard {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l.vpnStatus)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)

                            HStack(spacing: 8) {
                                StatusBadge(
                                    isActive: state.vpnMonitor.isConnected,
                                    activeText: l.connected,
                                    inactiveText: l.notConnected,
                                    activeColor: .green
                                )

                                if let uptime = state.stats.vpnUptime {
                                    Text(StatisticsManager.formatDuration(uptime))
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Spacer()

                        Image(systemName: state.vpnMonitor.isConnected ? "checkmark.shield.fill" : "shield.slash.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                state.vpnMonitor.isConnected
                                    ? LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(colors: [.red, .orange], startPoint: .top, endPoint: .bottom)
                            )
                    }

                    if state.vpnMonitor.isConnected {
                        Divider()

                        if state.vpnMonitor.allInterfaces.count > 1 {
                            Text(l.vpnInterfaces)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        ForEach(state.vpnMonitor.allInterfaces) { iface in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Interface")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Text(iface.name)
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("IP")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Text(iface.ip)
                                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                                }
                            }

                            if iface.id != state.vpnMonitor.allInterfaces.last?.id {
                                Divider().opacity(0.5)
                            }
                        }
                    }
                }
            }

            // Sleep Protection
            GlassCard {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(l.sleepProtection)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        HStack(spacing: 8) {
                            StatusBadge(
                                isActive: state.sleepManager.isPreventingSleep,
                                activeText: l.active,
                                inactiveText: state.isEnabled ? l.waiting : l.disabled,
                                activeColor: .purple
                            )

                            if let duration = state.stats.sleepPreventionDuration {
                                Text("\(state.stats.formatDurationLong(duration)) \(l.protectedFor)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { state.isEnabled },
                        set: { _ in state.toggle() }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
            }

            // Network Traffic
            GlassCard {
                VStack(spacing: 12) {
                    HStack {
                        Text(l.networkTraffic)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                        if state.vpnMonitor.isConnected {
                            Text("\(l.total): \(state.vpnMonitor.networkStats.formatBytes(state.vpnMonitor.networkStats.sessionDownload + state.vpnMonitor.networkStats.sessionUpload))")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(spacing: 12) {
                        SpeedGauge(
                            label: l.download,
                            speed: state.vpnMonitor.networkStats.downloadSpeed,
                            icon: "arrow.down.circle.fill",
                            color: .blue,
                            formatter: state.vpnMonitor.networkStats.formatSpeed
                        )

                        SpeedGauge(
                            label: l.upload,
                            speed: state.vpnMonitor.networkStats.uploadSpeed,
                            icon: "arrow.up.circle.fill",
                            color: .orange,
                            formatter: state.vpnMonitor.networkStats.formatSpeed
                        )
                    }

                    if !state.vpnMonitor.isConnected {
                        Text(l.vpnNotConnected)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }

            // Daily Statistics
            GlassCard {
                VStack(spacing: 12) {
                    Text(l.todayStats)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        StatItem(
                            value: "\(state.stats.todayConnectionCount)",
                            label: l.connections,
                            color: .green
                        )

                        Divider()
                            .frame(height: 40)

                        StatItem(
                            value: "\(state.stats.todayDisconnectionCount)",
                            label: l.disconnections,
                            color: .red
                        )
                    }
                }
            }

        }
    }

    var settingsSection: some View {
        VStack(spacing: 16) {
            // Language Selection
            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(l.language)
                        .font(.system(size: 13, weight: .semibold))

                    Picker("", selection: $l.currentLanguage) {
                        ForEach(Language.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text(l.checkInterval)
                        .font(.system(size: 13, weight: .semibold))

                    Picker("", selection: Binding(
                        get: { state.settings.checkInterval },
                        set: {
                            state.settings.checkInterval = $0
                            state.startMonitoring()
                        }
                    )) {
                        Text("5 \(l.seconds)").tag(5.0)
                        Text("10 \(l.seconds)").tag(10.0)
                        Text("30 \(l.seconds)").tag(30.0)
                        Text("60 \(l.seconds)").tag(60.0)
                    }
                    .pickerStyle(.segmented)
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(l.notifications)
                        .font(.system(size: 13, weight: .semibold))

                    Toggle(l.showNotifications, isOn: $state.settings.notificationsEnabled)
                        .font(.system(size: 13))

                    Toggle(l.soundAlert, isOn: $state.settings.soundEnabled)
                        .font(.system(size: 13))

                    Toggle(l.showUptimeInMenuBar, isOn: $state.settings.showUptimeInMenuBar)
                        .font(.system(size: 13))
                }
            }

            // Launch at Login
            if #available(macOS 13.0, *) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: Binding(
                            get: {
                                SMAppService.mainApp.status == .enabled
                            },
                            set: { newValue in
                                do {
                                    if newValue {
                                        try SMAppService.mainApp.register()
                                        LogManager.shared.log("Launch at login enabled", type: "APP")
                                    } else {
                                        try SMAppService.mainApp.unregister()
                                        LogManager.shared.log("Launch at login disabled", type: "APP")
                                    }
                                } catch {
                                    LogManager.shared.log("Launch at login error: \(error.localizedDescription)", type: "ERROR")
                                }
                            }
                        )) {
                            Text(l.launchAtLogin)
                                .font(.system(size: 13, weight: .semibold))
                        }

                        Text(l.launchAtLoginNote)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }

            GlassCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(l.logFile)
                        .font(.system(size: 13, weight: .semibold))

                    Text(LogManager.shared.logFilePath)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Button(action: {
                        NSWorkspace.shared.selectFile(LogManager.shared.logFilePath, inFileViewerRootedAtPath: "")
                    }) {
                        Label(l.openInFinder, systemImage: "folder")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
            }

            // About Section
            GlassCard {
                VStack(spacing: 16) {
                    // App Icon and Name
                    VStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                        Text("VPN Keep Awake")
                            .font(.system(size: 16, weight: .bold))

                        Text("\(l.version) 1.1.0")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Developer Info
                    VStack(spacing: 8) {
                        HStack {
                            Text(l.developer)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Softviser")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        HStack {
                            Text(l.website)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "https://www.softviser.com.tr") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("www.softviser.com.tr")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                        }

                        HStack {
                            Text("GitHub")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "https://github.com/softviser/VPNKeepAwake") {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Text("softviser/VPNKeepAwake")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                        }

                        HStack {
                            Text(l.license)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("MIT License")
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                        }
                    }

                    Divider()

                    // Footer
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "swift")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text(l.madeWith)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Text(l.freeAndOpenSource)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
    }
}

// MARK: - Floating Panel Window
class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 620),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true

        self.contentView = NSHostingView(rootView: DashboardView())
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.cornerRadius = 16
        self.contentView?.layer?.masksToBounds = true

        self.center()
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panel: FloatingPanel?
    private var iconTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        LogManager.shared.log("App started", type: "APP")

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.action = #selector(togglePanel)
            button.target = self
        }

        updateIcon()
        iconTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateIcon()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showPanel()
        }
    }

    @objc private func togglePanel() {
        if let panel = panel, panel.isVisible {
            panel.orderOut(nil)
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        if panel == nil {
            panel = FloatingPanel()
        }
        panel?.center()
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }

        let state = AppState.shared
        let isConnected = state.vpnMonitor.isConnected
        let isSleepPrevented = state.sleepManager.isPreventingSleep
        let isEnabled = state.isEnabled

        if #available(macOS 11.0, *) {
            let symbolName: String

            if !isEnabled {
                symbolName = "moon.zzz"
            } else if isConnected && isSleepPrevented {
                symbolName = "lock.shield.fill"
            } else if isConnected {
                symbolName = "shield.fill"
            } else {
                symbolName = "shield.slash"
            }

            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "VPN Keep Awake") {
                let configuredImage = image.withSymbolConfiguration(config)
                configuredImage?.isTemplate = true
                button.image = configuredImage
            }
        } else {
            button.title = isConnected && isSleepPrevented ? "🛡️" : (isConnected ? "⚠️" : "💤")
        }

        // Menu bar uptime display
        if isConnected && isEnabled && state.settings.showUptimeInMenuBar, let uptime = state.stats.vpnUptime {
            let h = Int(uptime) / 3600
            let m = (Int(uptime) % 3600) / 60
            button.title = h > 0 ? String(format: " %d:%02d", h, m) : String(format: " %dm", m)
        } else {
            button.title = ""
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppState.shared.sleepManager.allowSleep()
        iconTimer?.invalidate()
        LogManager.shared.log("App terminated", type: "APP")
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
