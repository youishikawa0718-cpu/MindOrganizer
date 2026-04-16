import Foundation
import SwiftData

@Model
final class Snapshot {
    @Attribute(.unique) var id: UUID
    var label: String?
    var createdAt: Date
    var treeJSON: Data

    var tree: ThoughtTree?

    init(label: String? = nil, treeJSON: Data, tree: ThoughtTree? = nil) {
        self.id = UUID()
        self.label = label
        self.createdAt = Date()
        self.treeJSON = treeJSON
        self.tree = tree
    }
}

