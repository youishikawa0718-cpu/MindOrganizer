import Foundation
import SwiftData

@Model
final class ThoughtTree {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool
    var colorHex: String?

    @Relationship(deleteRule: .cascade, inverse: \ThoughtNode.tree)
    var nodes: [ThoughtNode]

    @Relationship(deleteRule: .nullify, inverse: \Tag.trees)
    var tags: [Tag]

    @Relationship(deleteRule: .cascade, inverse: \Snapshot.tree)
    var snapshots: [Snapshot]

    var rootNodes: [ThoughtNode] {
        nodes.filter { $0.parent == nil }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    init(
        title: String,
        colorHex: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isPinned = false
        self.colorHex = colorHex
        self.nodes = []
        self.tags = []
        self.snapshots = []
    }
}
