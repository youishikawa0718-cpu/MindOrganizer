import Foundation
import SwiftData
import Observation

@Observable
final class TreeEditorViewModel {
    static let maxNodeCount = 1000
    static let maxDepth = 20

    let tree: ThoughtTree
    private let modelContext: ModelContext

    var flatNodes: [ThoughtNode] = []
    var editingNode: ThoughtNode?
    var isAddingNode = false
    var newNodeText = ""
    var addingParent: ThoughtNode?
    var alertMessage: String?

    init(tree: ThoughtTree, modelContext: ModelContext) {
        self.tree = tree
        self.modelContext = modelContext
        rebuildFlatNodes()
    }

    // MARK: - Flatten Tree

    func rebuildFlatNodes() {
        flatNodes = flatten(nodes: tree.rootNodes)
    }

    private func flatten(nodes: [ThoughtNode]) -> [ThoughtNode] {
        var result: [ThoughtNode] = []
        for node in nodes.sorted(by: { $0.sortOrder < $1.sortOrder }) {
            result.append(node)
            if !node.isCollapsed {
                result.append(contentsOf: flatten(nodes: node.sortedChildren))
            }
        }
        return result
    }

    // MARK: - CRUD

    func addRootNode(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard tree.nodes.count < Self.maxNodeCount else {
            alertMessage = "ノード数の上限（\(Self.maxNodeCount)）に達しました"
            return
        }
        let node = ThoughtNode(
            text: trimmed,
            sortOrder: tree.rootNodes.count,
            depth: 0,
            tree: tree
        )
        modelContext.insert(node)
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    func addChildNode(to parent: ThoughtNode, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard tree.nodes.count < Self.maxNodeCount else {
            alertMessage = "ノード数の上限（\(Self.maxNodeCount)）に達しました"
            return
        }
        guard parent.depth + 1 < Self.maxDepth else {
            alertMessage = "ツリーの深さの上限（\(Self.maxDepth)階層）に達しました"
            return
        }
        let node = ThoughtNode(
            text: trimmed,
            sortOrder: parent.children.count,
            depth: parent.depth + 1,
            tree: tree,
            parent: parent
        )
        modelContext.insert(node)
        parent.isCollapsed = false
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    func addSiblingNode(after sibling: ThoughtNode, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let siblings: [ThoughtNode]
        if let parent = sibling.parent {
            siblings = parent.sortedChildren
        } else {
            siblings = tree.rootNodes
        }

        // Shift sort orders
        for node in siblings where node.sortOrder > sibling.sortOrder {
            node.sortOrder += 1
        }

        let node = ThoughtNode(
            text: trimmed,
            sortOrder: sibling.sortOrder + 1,
            depth: sibling.depth,
            tree: tree,
            parent: sibling.parent
        )
        modelContext.insert(node)
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    func updateNode(_ node: ThoughtNode, text: String, note: String?) {
        node.text = text
        node.note = note
        node.updatedAt = Date()
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    func deleteNode(_ node: ThoughtNode) {
        modelContext.delete(node)
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    func toggleCollapse(_ node: ThoughtNode) {
        guard !node.children.isEmpty else { return }
        node.isCollapsed.toggle()
        rebuildFlatNodes()
    }

    // MARK: - Add Node Flow

    func startAddingChild(to parent: ThoughtNode?) {
        addingParent = parent
        newNodeText = ""
        isAddingNode = true
    }

    func confirmAddNode() {
        if let parent = addingParent {
            addChildNode(to: parent, text: newNodeText)
        } else {
            addRootNode(text: newNodeText)
        }
        isAddingNode = false
        newNodeText = ""
        addingParent = nil
    }

    func cancelAddNode() {
        isAddingNode = false
        newNodeText = ""
        addingParent = nil
    }

    // MARK: - Indent / Outdent

    func indentNode(_ node: ThoughtNode) {
        let siblings: [ThoughtNode]
        if let parent = node.parent {
            siblings = parent.sortedChildren
        } else {
            siblings = tree.rootNodes
        }

        guard let index = siblings.firstIndex(where: { $0.id == node.id }),
              index > 0 else { return }

        guard node.depth + 1 < Self.maxDepth else {
            alertMessage = "ツリーの深さの上限（\(Self.maxDepth)階層）に達しました"
            return
        }

        let newParent = siblings[index - 1]
        node.parent = newParent
        node.depth += 1
        node.sortOrder = newParent.children.count
        updateChildDepths(of: node)
        newParent.isCollapsed = false
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    func outdentNode(_ node: ThoughtNode) {
        guard let currentParent = node.parent else { return }

        node.parent = currentParent.parent
        node.depth -= 1
        node.sortOrder = (currentParent.parent?.children.count ?? tree.rootNodes.count)
        updateChildDepths(of: node)
        tree.updatedAt = Date()
        rebuildFlatNodes()
    }

    private func updateChildDepths(of node: ThoughtNode) {
        for child in node.children {
            child.depth = node.depth + 1
            updateChildDepths(of: child)
        }
    }
}
