import Foundation
import SwiftData

/// スナップショット用のノードDTO（Codable）
struct SnapshotNodeDTO: Codable, Identifiable {
    let id: UUID
    let text: String
    let note: String?
    let sortOrder: Int
    let depth: Int
    let children: [SnapshotNodeDTO]
}

enum SnapshotService {

    // MARK: - Save

    /// ツリー全体をスナップショットとして保存
    static func save(
        tree: ThoughtTree,
        label: String?,
        modelContext: ModelContext
    ) throws {
        let dto = tree.rootNodes.map { buildDTO(from: $0) }
        let data = try JSONEncoder().encode(dto)
        let trimmedLabel = label?.trimmingCharacters(in: .whitespaces)
        let snapshot = Snapshot(
            label: (trimmedLabel?.isEmpty == false) ? trimmedLabel : nil,
            treeJSON: data,
            tree: tree
        )
        modelContext.insert(snapshot)
    }

    // MARK: - Decode

    /// スナップショットのJSONをDTO配列にデコード
    static func decode(_ snapshot: Snapshot) throws -> [SnapshotNodeDTO] {
        try JSONDecoder().decode([SnapshotNodeDTO].self, from: snapshot.treeJSON)
    }

    // MARK: - Delete

    static func delete(
        _ snapshot: Snapshot,
        modelContext: ModelContext
    ) {
        modelContext.delete(snapshot)
    }

    // MARK: - Private

    private static func buildDTO(from node: ThoughtNode) -> SnapshotNodeDTO {
        SnapshotNodeDTO(
            id: node.id,
            text: node.text,
            note: node.note,
            sortOrder: node.sortOrder,
            depth: node.depth,
            children: node.sortedChildren.map { buildDTO(from: $0) }
        )
    }
}
