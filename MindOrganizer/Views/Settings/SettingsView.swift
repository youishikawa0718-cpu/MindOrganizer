import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trees: [ThoughtTree]
    @Query private var tags: [Tag]
    @AppStorage("appearance") private var appearance = Appearance.system

    var body: some View {
        Form {
            Section("外観") {
                Picker("テーマ", selection: $appearance) {
                    ForEach(Appearance.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
            }

            Section("データ") {
                LabeledContent("テーマ数", value: "\(trees.count)")
                LabeledContent("タグ数", value: "\(tags.count)")
            }

            Section("情報") {
                LabeledContent("バージョン", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
            }
        }
        .navigationTitle("設定")
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
