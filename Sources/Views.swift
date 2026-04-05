import SwiftUI
import Cocoa
import ServiceManagement

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

            GlassCard {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                        Text("VPN Keep Awake")
                            .font(.system(size: 16, weight: .bold))

                        Text("\(l.version) \(AppConstants.shortVersion)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Divider()

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
                                guard let url = AppConstants.websiteURL else { return }
                                NSWorkspace.shared.open(url)
                            }) {
                                Text(AppConstants.websiteDisplayText)
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
                                guard let url = AppConstants.githubURL else { return }
                                NSWorkspace.shared.open(url)
                            }) {
                                Text(AppConstants.githubDisplayText)
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
