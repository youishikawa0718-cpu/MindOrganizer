import Foundation
import SwiftData

enum PreviewData {
    static func createSampleTree(in context: ModelContext) -> ThoughtTree {
        let tree = ThoughtTree(title: "転職すべきか？")
        context.insert(tree)

        let merit = ThoughtNode(text: "メリット", sortOrder: 0, depth: 0, tree: tree)
        context.insert(merit)

        let income = ThoughtNode(text: "年収UP", sortOrder: 0, depth: 1, tree: tree, parent: merit)
        context.insert(income)

        let challenge = ThoughtNode(text: "新しい挑戦", sortOrder: 1, depth: 1, tree: tree, parent: merit)
        context.insert(challenge)

        let demerit = ThoughtNode(text: "デメリット", sortOrder: 1, depth: 0, tree: tree)
        context.insert(demerit)

        let relations = ThoughtNode(text: "人間関係リセット", sortOrder: 0, depth: 1, tree: tree, parent: demerit)
        context.insert(relations)

        let stability = ThoughtNode(text: "安定性", sortOrder: 1, depth: 1, tree: tree, parent: demerit)
        context.insert(stability)

        let tag = Tag(name: "仕事", colorHex: "4ECDC4")
        context.insert(tag)
        tree.tags.append(tag)

        return tree
    }
}
