import Foundation
import FirebaseFirestore

struct ThoughtNodeDTO: Codable, Sendable {
    let id: String
    let text: String
    let note: String?
    let parentId: String?
    let sortOrder: Int
    let depth: Int
    let isCollapsed: Bool
    let createdAt: Date
    let updatedAt: Date

    init(from node: ThoughtNode) {
        self.id = node.id.uuidString
        self.text = node.text
        self.note = node.note
        self.parentId = node.parent?.id.uuidString
        self.sortOrder = node.sortOrder
        self.depth = node.depth
        self.isCollapsed = node.isCollapsed
        self.createdAt = node.createdAt
        self.updatedAt = node.updatedAt
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "text": text,
            "sortOrder": sortOrder,
            "depth": depth,
            "isCollapsed": isCollapsed,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt),
        ]
        if let note { dict["note"] = note }
        if let parentId { dict["parentId"] = parentId }
        return dict
    }
}
