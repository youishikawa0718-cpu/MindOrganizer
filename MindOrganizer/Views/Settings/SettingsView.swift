import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var trees: [ThoughtTree]
    @Query private var tags: [Tag]
    @AppStorage("appearance") private var appearance = Appearance.system
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    @State private var showingAuthSheet = false
    @State private var showingDeleteConfirm = false
    @State private var showingDeleteFinalConfirm = false
    @State private var syncService = SyncService()
    @State private var errorMessage: String?

    private let authRepository = AuthRepository()

    var body: some View {
        ZStack {
            Color.moBg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    profileCard
                    if appState.isAuthenticated {
                        syncSection
                    }
                    appearanceSection
                    accentSection
                    dataSection
                    if appState.isAuthenticated {
                        dangerSection
                    }
                    infoSection
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("設定")
        .toolbarBackground(Color.moBg, for: .navigationBar)
        .sheet(isPresented: $showingAuthSheet) {
            AuthView()
        }
        .alert("アカウントを削除しますか？", isPresented: $showingDeleteConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("次へ", role: .destructive) {
                showingDeleteFinalConfirm = true
            }
        } message: {
            Text("すべてのクラウドデータが完全に削除されます。ローカルデータは残ります。")
        }
        .alert("本当に削除しますか？", isPresented: $showingDeleteFinalConfirm) {
            Button("キャンセル", role: .cancel) {}
            Button("アカウントを削除", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("この操作は取り消せません。")
        }
        .onAppear {
            syncService.setPendingContext(modelContext)
        }
        .alert("エラー", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        HStack(spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 3) {
                if appState.isAuthenticated {
                    Text(appState.currentUser?.displayName ?? "ユーザー")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.moInk)
                        .lineLimit(1)
                    if let email = appState.currentUser?.email {
                        Text(email)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.moInkMuted)
                            .lineLimit(1)
                    }
                } else {
                    Text("ゲストモード")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.moInk)
                    Text("ローカルのみで利用中")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.moInkMuted)
                }
            }

            Spacer(minLength: 0)

            if appState.isAuthenticated {
                syncedBadge
            } else {
                Button {
                    showingAuthSheet = true
                } label: {
                    Text("ログイン")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.moBg)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.moInk)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.moBgElev)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.moHair, lineWidth: 1)
        )
    }

    private var avatar: some View {
        let initials = avatarInitials
        return ZStack {
            Circle().fill(Color.moAccent(accentKey))
            Text(initials)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 48, height: 48)
    }

    private var avatarInitials: String {
        let name = appState.currentUser?.displayName ?? appState.currentUser?.email ?? "Guest"
        let words = name.split(separator: " ").prefix(2)
        let initials = words.compactMap { $0.first }.map { String($0) }.joined()
        return initials.isEmpty ? String(name.prefix(2)).uppercased() : initials.uppercased()
    }

    private var syncedBadge: some View {
        Text("SYNCED")
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .tracking(1.5)
            .foregroundStyle(Color.moAccent(accentKey))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(Color.moAccent(accentKey).opacity(0.15))
            )
    }

    // MARK: - Sections

    private var syncSection: some View {
        section(kicker: "Sync", title: "同期") {
            row {
                Text("クラウド同期").foregroundStyle(Color.moInk)
                Spacer()
                if syncService.isSyncing {
                    ProgressView().scaleEffect(0.8)
                } else {
                    Button("今すぐ同期") {
                        performSync()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.moAccent(accentKey))
                }
            }
            if let lastSynced = syncService.lastSyncedAt {
                divider
                row {
                    Text("最終同期").foregroundStyle(Color.moInk)
                    Spacer()
                    Text(lastSynced.shortDisplay)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.moInkMuted)
                }
            }
            if let error = syncService.syncError {
                divider
                row {
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.moDanger)
                }
            }
        }
    }

    private var appearanceSection: some View {
        section(kicker: "Appearance", title: "外観") {
            VStack(alignment: .leading, spacing: 12) {
                Text("テーマ")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.moInk)
                SegmentedMini(
                    selection: $appearance,
                    options: Appearance.allCases.map {
                        .init(value: $0, label: $0.displayName)
                    }
                )
            }
            .padding(.vertical, 4)
        }
    }

    private var accentSection: some View {
        section(kicker: "Accent Color", title: "アクセントカラー") {
            HStack(spacing: 12) {
                ForEach(AccentPreset.allCases) { preset in
                    accentSwatch(preset)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func accentSwatch(_ preset: AccentPreset) -> some View {
        let isSelected = accentKey == preset.rawValue
        return Button {
            accentKey = preset.rawValue
        } label: {
            ZStack {
                Circle().fill(preset.color)
                if isSelected {
                    Circle()
                        .strokeBorder(Color.moInk, lineWidth: 2)
                        .padding(-3)
                }
            }
            .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.displayName)
    }

    private var dataSection: some View {
        section(kicker: "Data", title: "データ") {
            row {
                Text("テーマ数").foregroundStyle(Color.moInk)
                Spacer()
                Text("\(trees.count)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.moInkMuted)
            }
            divider
            row {
                Text("タグ数").foregroundStyle(Color.moInk)
                Spacer()
                Text("\(tags.count)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.moInkMuted)
            }
        }
    }

    private var dangerSection: some View {
        section(kicker: "Danger Zone", title: "危険な操作", kickerTone: .accent(.moDanger)) {
            Button {
                signOut()
            } label: {
                row {
                    Text("ログアウト")
                        .foregroundStyle(Color.moDanger)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.moInkFaint)
                }
            }
            .buttonStyle(.plain)
            divider
            Button {
                showingDeleteConfirm = true
            } label: {
                row {
                    Text("アカウントを削除")
                        .foregroundStyle(Color.moDanger)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.moInkFaint)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var infoSection: some View {
        section(kicker: "About", title: "情報") {
            row {
                Text("バージョン").foregroundStyle(Color.moInk)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.moInkMuted)
            }
            divider
            Link(destination: URL(string: "https://youishikawa0718-cpu.github.io/mindorganizer-privacy")!) {
                row {
                    Text("プライバシーポリシー").foregroundStyle(Color.moInk)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.moInkFaint)
                }
            }
        }
    }

    private var footer: some View {
        Text("MINDORGANIZER · MADE WITH CARE")
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .tracking(2)
            .foregroundStyle(Color.moInkFaint)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
    }

    // MARK: - Section helpers

    @ViewBuilder
    private func section<Content: View>(
        kicker: String,
        title: String,
        kickerTone: MoKicker.Tone = .faint,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                MoKicker(text: kicker, tone: kickerTone)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.moInk)
            }
            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.moBgElev)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.moHair, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack {
            content()
        }
        .font(.system(size: 15))
        .frame(minHeight: 44)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.moHair)
            .frame(height: 1)
    }

    // MARK: - Actions

    private func signOut() {
        do {
            try authRepository.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSync() {
        Task {
            await syncService.syncAll(modelContext: modelContext)
        }
    }

    private func deleteAccount() {
        Task {
            do {
                let remoteRepo = RemoteThoughtRepository()
                try await remoteRepo.deleteAllUserData()
                try await authRepository.deleteAccount()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

enum Appearance: String, CaseIterable, Identifiable, Hashable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "システム"
        case .light: "ライト"
        case .dark: "ダーク"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
