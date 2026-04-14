import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var trees: [ThoughtTree]
    @Query private var tags: [Tag]
    @AppStorage("appearance") private var appearance = Appearance.system

    @State private var showingAuthSheet = false
    @State private var showingDeleteConfirm = false
    @State private var showingDeleteFinalConfirm = false
    @State private var syncService = SyncService()
    @State private var errorMessage: String?

    private let authRepository = AuthRepository()

    var body: some View {
        Form {
            // MARK: - Account
            Section("アカウント") {
                if appState.isAuthenticated {
                    if let email = appState.currentUser?.email {
                        LabeledContent("メール", value: email)
                    }
                    if let displayName = appState.currentUser?.displayName {
                        LabeledContent("名前", value: displayName)
                    }

                    Button("ログアウト", role: .destructive) {
                        signOut()
                    }
                } else {
                    HStack {
                        Text("ゲストモード")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("ログイン") {
                            showingAuthSheet = true
                        }
                    }
                }
            }

            // MARK: - Sync
            if appState.isAuthenticated {
                Section("同期") {
                    HStack {
                        Text("クラウド同期")
                        Spacer()
                        if syncService.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Button("今すぐ同期") {
                                performSync()
                            }
                        }
                    }
                    if let lastSynced = syncService.lastSyncedAt {
                        LabeledContent("最終同期", value: lastSynced.shortDisplay)
                    }
                    if let error = syncService.syncError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }

            // MARK: - Appearance
            Section("外観") {
                Picker("テーマ", selection: $appearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }

            // MARK: - Data
            Section("データ") {
                LabeledContent("テーマ数", value: "\(trees.count)")
                LabeledContent("タグ数", value: "\(tags.count)")
            }

            // MARK: - Danger Zone
            if appState.isAuthenticated {
                Section {
                    Button("アカウントを削除", role: .destructive) {
                        showingDeleteConfirm = true
                    }
                } footer: {
                    Text("アカウントとすべてのクラウドデータが削除されます。この操作は取り消せません。")
                }
            }

            // MARK: - Info
            Section("情報") {
                LabeledContent("バージョン", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                Link(destination: URL(string: "https://yukiishikawa.github.io/mindorganizer-privacy")!) {
                    HStack {
                        Text("プライバシーポリシー")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("設定")
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

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "システム設定"
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
