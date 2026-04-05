import Cocoa
import SwiftUI

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

        AppState.shared.sleepManager.checkAccessibilityPermission()
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
