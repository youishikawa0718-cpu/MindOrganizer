import Foundation
import SwiftData

@Model
final class ThoughtNode {
    @Attribute(.unique) var id: UUID
    var text: String
    var note: String?
    var sortOrder: Int
    var depth: Int
    var isCollapsed: Bool
    var createdAt: Date
    var updatedAt: Date

    var tree: ThoughtTree?
    var parent: ThoughtNode?

    @Relationship(deleteRule: .cascade, inverse: \ThoughtNode.parent)
    var children: [ThoughtNode]

    var sortedChildren: [ThoughtNode] {
        children.sorted { $0.sortOrder < $1.sortOrder }
    }

    init(
        text: String,
        note: String? = nil,
        sortOrder: Int = 0,
        depth: Int = 0,
        tree: ThoughtTree? = nil,
        parent: ThoughtNode? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.note = note
        self.sortOrder = sortOrder
        self.depth = depth
        self.isCollapsed = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tree = tree
        self.parent = parent
        self.children = []
    }
}
