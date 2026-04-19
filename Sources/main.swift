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
    private let logQueue = DispatchQueue(label: "com.softviser.vpnkeepawake.log", qos: .utility)

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
        guard let data = logLine.data(using: .utf8) else { return }

        logQueue.async {
            let handle = FileHandle(forWritingAtPath: self.logFile.path)
            if handle == nil {
                do {
                    try data.write(to: self.logFile)
                } catch {
                    print("Failed to create log file: \(error)")
                }
                return
            }
            defer { handle?.closeFile() }
            handle?.seekToEndOfFile()
            handle?.write(data)
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
                DispatchQueue.main.async {
                    SettingsManager.shared.notificationsEnabled = false
                }
                return
            }
            LogManager.shared.log("Notification permission: \(granted ? "granted" : "denied")", type: "PERM")
            if !granted {
                DispatchQueue.main.async {
                    SettingsManager.shared.notificationsEnabled = false
                }
            }
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
                DispatchQueue.main.async {
                    SettingsManager.shared.notificationsEnabled = false
                }
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
    private var systemAssertionID: IOPMAssertionID = UInt32.max
    private var displayAssertionID: IOPMAssertionID = UInt32.max
    private var systemAssertionCreated = false
    private var displayAssertionCreated = false
    private var activityTimer: Timer?

    deinit {
        allowSleep()
    }

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

        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &systemAssertionID
        )

        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &displayAssertionID
        )

        if systemResult == kIOReturnSuccess {
            systemAssertionCreated = true
            if displayResult == kIOReturnSuccess {
                displayAssertionCreated = true
            }

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

        if systemAssertionCreated {
            IOPMAssertionRelease(systemAssertionID)
            systemAssertionID = UInt32.max
            systemAssertionCreated = false
        }

        if displayAssertionCreated {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = UInt32.max
            displayAssertionCreated = false
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
        IOPMAssertionDeclareUserActivity(
            "VPN Keep Awake - activity" as CFString,
            kIOPMUserActiveLocal,
            nil
        )

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
                        let result = inet_ntop(AF_INET, &sockAddr.sin_addr, &hostname, socklen_t(NI_MAXHOST))
                        guard result != nil else { continue }
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

        sleepManager.checkAccessibilityPermission()
        
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


// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
