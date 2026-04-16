import SwiftUI
import SwiftData

struct SnapshotListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let tree: ThoughtTree

    @State private var showingLabelAlert = false
    @State private var snapshotLabel = ""

    private var sortedSnapshots: [Snapshot] {
        (tree.snapshots).sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sortedSnapshots.isEmpty {
                    ContentUnavailableView {
                        Label("スナップショットなし", systemImage: "camera")
                    } description: {
                        Text("現在のツリーを保存して\nあとから振り返れます")
                    }
                } else {
                    List {
                        ForEach(sortedSnapshots) { snapshot in
                            NavigationLink {
                                SnapshotDetailView(snapshot: snapshot)
                            } label: {
                                row(for: snapshot)
                            }
                        }
                        .onDelete(perform: deleteSnapshots)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("スナップショット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        snapshotLabel = ""
                        showingLabelAlert = true
                    } label: {
                        Image(systemName: "camera.fill")
                    }
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

    // MARK: - Row

    private func row(for snapshot: Snapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(snapshot.label ?? "無題のスナップショット")
                .font(.body)
                .fontWeight(snapshot.label != nil ? .medium : .regular)
                .foregroundStyle(snapshot.label != nil ? .primary : .secondary)
            Text(snapshot.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
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

    private func deleteSnapshots(at offsets: IndexSet) {
        for index in offsets {
            let snapshot = sortedSnapshots[index]
            SnapshotService.delete(snapshot, modelContext: modelContext)
        }
    }
}
