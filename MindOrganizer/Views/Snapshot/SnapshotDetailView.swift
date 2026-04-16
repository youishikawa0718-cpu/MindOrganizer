import SwiftUI

struct SnapshotDetailView: View {
    let snapshot: Snapshot

    @State private var rootNodes: [SnapshotNodeDTO] = []
    @State private var decodeError = false

    var body: some View {
        Group {
            if decodeError {
                ContentUnavailableView(
                    "読み込みエラー",
                    systemImage: "exclamationmark.triangle",
                    description: Text("スナップショットのデータを復元できませんでした")
                )
            } else if rootNodes.isEmpty {
                ContentUnavailableView(
                    "ノードなし",
                    systemImage: "leaf",
                    description: Text("このスナップショットにはノードがありません")
                )
            } else {
                List {
                    ForEach(flattenDTO(rootNodes)) { item in
                        nodeRow(item)
                            .listRowInsets(EdgeInsets(
                                top: 4,
                                leading: CGFloat(item.depth) * 24 + 16,
                                bottom: 4,
                                trailing: 16
                            ))
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(snapshot.label ?? "スナップショット")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            do {
                rootNodes = try SnapshotService.decode(snapshot)
            } catch {
                decodeError = true
            }
        }
    }

    // MARK: - Node Row

    private func nodeRow(_ node: SnapshotNodeDTO) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(node.text)
                .font(.body)
            if let note = node.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Flatten

    private func flattenDTO(_ nodes: [SnapshotNodeDTO]) -> [SnapshotNodeDTO] {
        var result: [SnapshotNodeDTO] = []
        for node in nodes.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            result.append(node)
            result.append(contentsOf: flattenDTO(node.children))
        }
        return result
    }
}
