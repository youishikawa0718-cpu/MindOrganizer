import SwiftUI
import SwiftData

struct SnapshotListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("accentKey") private var accentKey: String = "indigo"
    let tree: ThoughtTree

    @State private var showingLabelAlert = false
    @State private var snapshotLabel = ""

    private var sortedSnapshots: [Snapshot] {
        tree.snapshots.sorted { $0.createdAt > $1.createdAt }
    }

    private var accent: Color { Color.moAccent(accentKey) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moBg.ignoresSafeArea()

                Group {
                    if sortedSnapshots.isEmpty {
                        emptyState
                    } else {
                        timeline
                    }
                }
            }
            .navigationTitle("スナップショット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moBg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundStyle(Color.moInkMuted)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        snapshotLabel = ""
                        showingLabelAlert = true
                    } label: {
                        Image(systemName: "camera.fill")
                            .foregroundStyle(accent)
                    }
                    .accessibilityLabel("スナップショットを作成")
                }
            }
            .alert("スナップショットを保存", isPresented: $showingLabelAlert) {
                TextField("ラベル（任意）", text: $snapshotLabel)
                Button("保存") { saveSnapshot() }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("現在のツリー状態を保存します")
            }
        }
    }

    // MARK: - Timeline

    private var timeline: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.moHairStrong)
                    .frame(width: 1)
                    .padding(.leading, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                LazyVStack(spacing: 16) {
                    ForEach(Array(sortedSnapshots.enumerated()), id: \.element.id) { index, snapshot in
                        entry(snapshot, isLatest: index == 0)
                    }
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 16)
        }
    }

    private func entry(_ snapshot: Snapshot, isLatest: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            timelineDot(isLatest: isLatest)
                .padding(.top, 14)

            card(snapshot, isLatest: isLatest)
                .contextMenu {
                    Button(role: .destructive) {
                        deleteSnapshot(snapshot)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
        }
    }

    private func timelineDot(isLatest: Bool) -> some View {
        ZStack {
            if isLatest {
                Circle().fill(accent)
                    .frame(width: 11, height: 11)
            } else {
                Circle().fill(Color.moBgElev)
                    .frame(width: 11, height: 11)
                    .overlay(
                        Circle().strokeBorder(Color.moHairStrong, lineWidth: 2)
                    )
            }
        }
        .frame(width: 20)
        .padding(.leading, 15)
        .padding(.trailing, 12)
    }

    private func card(_ snapshot: Snapshot, isLatest: Bool) -> some View {
        NavigationLink {
            SnapshotDetailView(snapshot: snapshot)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text(snapshot.createdAt.formatted(.dateTime.year().month().day().hour().minute()))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(Color.moInkFaint)
                        .textCase(.uppercase)
                    Spacer()
                    if isLatest {
                        Text("最新")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(accent)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(accent.opacity(0.15))
                            )
                    }
                }

                if let label = snapshot.label, !label.isEmpty {
                    Text("“\(label)”")
                        .font(.system(size: 14))
                        .italic()
                        .foregroundStyle(Color.moInk)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("無題のスナップショット")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.moInkMuted)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.moBgElev)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.moHair, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color.moHairStrong,
                        style: StrokeStyle(lineWidth: 1, dash: [3, 5])
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: "camera")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.moInkFaint)
            }
            Text("スナップショットなし")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.moInk)
            Text("現在のツリーを保存して\nあとから振り返れます。")
                .font(.system(size: 14))
                .foregroundStyle(Color.moInkMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
            Button {
                snapshotLabel = ""
                showingLabelAlert = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                        .font(.system(size: 13, weight: .semibold))
                    Text("スナップショットを作成")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.moBg)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.moInk)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    // MARK: - Actions

    private func saveSnapshot() {
        do {
            try SnapshotService.save(
                tree: tree,
                label: snapshotLabel,
                modelContext: modelContext
            )
        } catch {
            // JSON encode failure — should not happen with valid data
        }
    }

    private func deleteSnapshot(_ snapshot: Snapshot) {
        SnapshotService.delete(snapshot, modelContext: modelContext)
    }
}
