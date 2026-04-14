import Foundation
import FirebaseFirestore

struct ThoughtTreeDTO: Codable, Sendable {
    let id: String
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let isPinned: Bool
    let colorHex: String?
    let tagIds: [String]
    let nodes: [ThoughtNodeDTO]

    init(from tree: ThoughtTree) {
        self.id = tree.id.uuidString
        self.title = tree.title
        self.createdAt = tree.createdAt
        self.updatedAt = tree.updatedAt
        self.isPinned = tree.isPinned
        self.colorHex = tree.colorHex
        self.tagIds = tree.tags.map { $0.id.uuidString }
        self.nodes = tree.nodes.map { ThoughtNodeDTO(from: $0) }
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
            "isPinned": isPinned,
            "tagIds": tagIds,
            "nodes": nodes.map { $0.toDict() },
        ]
        if let colorHex {
            dict["colorHex"] = colorHex
        }
        return dict
    }
}
