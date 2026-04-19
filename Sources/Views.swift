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
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.cardBorder.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 12, y: 6)
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
                .fill(isActive ? activeColor : AppTheme.textTertiary)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(isActive ? activeColor.opacity(0.5) : .clear, lineWidth: 2)
                        .scaleEffect(isActive ? 1.8 : 1)
                        .opacity(isActive ? 0 : 1)
                        .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: isActive)
                )
                .shadow(color: isActive ? activeColor.opacity(0.5) : .clear, radius: 4)

            Text(isActive ? activeText : inactiveText)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isActive ? activeColor : AppTheme.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isActive ? activeColor.opacity(0.15) : AppTheme.textTertiary.opacity(0.1))
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
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
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
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
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
                    .stroke(AppTheme.info.opacity(0.2), lineWidth: 2)
                    .frame(width: 16, height: 16)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppTheme.info, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
            }

            Text("\(l.nextUpdate): \(secondsRemaining)\(l.seconds)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
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
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                titleBar
                Divider().background(AppTheme.cardBorder.opacity(0.3))
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
                Divider().background(AppTheme.cardBorder.opacity(0.3))
                footerBar
            }
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
    }

    var titleBar: some View {
        HStack {
            Image(systemName: "shield.checkered")
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.primaryGradient)

            Text(l.appTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Button(action: { showSettings.toggle() }) {
                Image(systemName: showSettings ? "xmark.circle.fill" : "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    var footerBar: some View {
        HStack {
            AutoRefreshIndicator(
                secondsRemaining: state.secondsUntilNextUpdate,
                totalSeconds: Int(state.settings.checkInterval)
            )

            Spacer()

            Button(action: { showQuitAlert = true }) {
                Label(l.quit, systemImage: "power")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .buttonStyle(.plain)
            .foregroundColor(AppTheme.disconnected)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    var mainSection: some View {
        VStack(spacing: 16) {
            if !state.sleepManager.hasAccessibilityPermission {
                accessibilityWarning
            }
            vpnStatusCard
            sleepProtectionCard
            networkTrafficCard
            dailyStatsCard
        }
    }

    var accessibilityWarning: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.warning)

                    Text(l.accessibilityRequired)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.warning)

                    Spacer()
                }

                Text(l.accessibilityDescription)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {
                    state.sleepManager.requestAccessibilityPermission()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "gear")
                            .font(.system(size: 12))
                        Text(l.openSystemSettings)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.warning.opacity(0.15))
                    )
                    .foregroundColor(AppTheme.warning)
                }
                .buttonStyle(.plain)
            }
        }
    }

    var vpnStatusCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(l.vpnStatus)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)

                        HStack(spacing: 8) {
                            StatusBadge(
                                isActive: state.vpnMonitor.isConnected,
                                activeText: l.connected,
                                inactiveText: l.notConnected,
                                activeColor: AppTheme.connected
                            )

                            if let uptime = state.stats.vpnUptime {
                                Text(StatisticsManager.formatDuration(uptime))
                                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: state.vpnMonitor.isConnected ? "checkmark.shield.fill" : "shield.slash.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            state.vpnMonitor.isConnected ? AppTheme.connectedGradient : AppTheme.disconnectedGradient
                        )
                }

                if state.vpnMonitor.isConnected {
                    Divider().background(AppTheme.cardBorder.opacity(0.3))

                    if state.vpnMonitor.allInterfaces.count > 1 {
                        Text(l.vpnInterfaces)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ForEach(state.vpnMonitor.allInterfaces) { iface in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Interface")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(iface.name)
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("IP")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(iface.ip)
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }

                        if iface.id != state.vpnMonitor.allInterfaces.last?.id {
                            Divider().background(AppTheme.cardBorder.opacity(0.3))
                        }
                    }
                }
            }
        }
    }

    var sleepProtectionCard: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(l.sleepProtection)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)

                    HStack(spacing: 8) {
                        StatusBadge(
                            isActive: state.sleepManager.isPreventingSleep,
                            activeText: l.active,
                            inactiveText: state.isEnabled ? l.waiting : l.disabled,
                            activeColor: Color(hex: "8B5CF6")
                        )

                        if let duration = state.stats.sleepPreventionDuration {
                            Text("\(state.stats.formatDurationLong(duration)) \(l.protectedFor)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
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
    }

    var networkTrafficCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Text(l.networkTraffic)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    if state.vpnMonitor.isConnected {
                        Text("\(l.total): \(state.vpnMonitor.networkStats.formatBytes(state.vpnMonitor.networkStats.sessionDownload + state.vpnMonitor.networkStats.sessionUpload))")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                HStack(spacing: 12) {
                    SpeedGauge(
                        label: l.download,
                        speed: state.vpnMonitor.networkStats.downloadSpeed,
                        icon: "arrow.down.circle.fill",
                        color: AppTheme.info,
                        formatter: state.vpnMonitor.networkStats.formatSpeed
                    )

                    SpeedGauge(
                        label: l.upload,
                        speed: state.vpnMonitor.networkStats.uploadSpeed,
                        icon: "arrow.up.circle.fill",
                        color: Color(hex: "F97316"),
                        formatter: state.vpnMonitor.networkStats.formatSpeed
                    )
                }

                if !state.vpnMonitor.isConnected {
                    Text(l.vpnNotConnected)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(.top, 4)
                }
            }
        }
    }

    var dailyStatsCard: some View {
        GlassCard {
            VStack(spacing: 12) {
                Text(l.todayStats)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 0) {
                    StatItem(
                        value: "\(state.stats.todayConnectionCount)",
                        label: l.connections,
                        color: AppTheme.connected
                    )

                    Divider()
                        .frame(height: 40)
                        .background(AppTheme.cardBorder)

                    StatItem(
                        value: "\(state.stats.todayDisconnectionCount)",
                        label: l.disconnections,
                        color: AppTheme.disconnected
                    )
                }
            }
        }
    }

    var settingsSection: some View {
        VStack(spacing: 16) {
            languageCard
            checkIntervalCard
            notificationsCard
            launchAtLoginCard
            logFileCard
            aboutCard
        }
    }

    var languageCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(l.language)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Picker("", selection: $l.currentLanguage) {
                    ForEach(Language.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    var checkIntervalCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(l.checkInterval)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

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
    }

    var notificationsCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(l.notifications)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Toggle(l.showNotifications, isOn: $state.settings.notificationsEnabled)
                    .font(.system(size: 13, design: .rounded))

                Toggle(l.soundAlert, isOn: $state.settings.soundEnabled)
                    .font(.system(size: 13, design: .rounded))

                Toggle(l.showUptimeInMenuBar, isOn: $state.settings.showUptimeInMenuBar)
                    .font(.system(size: 13, design: .rounded))
            }
        }
    }

    var launchAtLoginCard: some View {
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
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }

                Text(l.launchAtLoginNote)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    var logFileCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(l.logFile)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))

                Text(LogManager.shared.logFilePath)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)

                Button(action: {
                    NSWorkspace.shared.selectFile(LogManager.shared.logFilePath, inFileViewerRootedAtPath: "")
                }) {
                    Label(l.openInFinder, systemImage: "folder")
                        .font(.system(size: 12, design: .rounded))
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.info)
            }
        }
    }

    var aboutCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.primaryGradient)

                    Text("VPN Keep Awake")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("\(l.version) \(AppConstants.shortVersion)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Divider().background(AppTheme.cardBorder)

                VStack(spacing: 8) {
                    aboutRow(label: l.developer, value: "Softviser", isLink: false)
                    aboutRow(label: l.website, value: AppConstants.websiteDisplayText, url: AppConstants.websiteURL)
                    aboutRow(label: "GitHub", value: AppConstants.githubDisplayText, url: AppConstants.githubURL)
                    aboutRow(label: l.license, value: "MIT License", isLink: false)
                }

                Divider().background(AppTheme.cardBorder)

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "swift")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "F97316"))
                        Text(l.madeWith)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Text(l.freeAndOpenSource)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
    }

    func aboutRow(label: String, value: String, isLink: Bool = false, url: URL? = nil) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            if isLink, let url = url {
                Button(action: { NSWorkspace.shared.open(url) }) {
                    Text(value)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.info)
            } else {
                Text(value)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
    }
}
