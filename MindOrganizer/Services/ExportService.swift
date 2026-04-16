import Foundation

enum ExportService {

    /// ツリーをマークダウン形式のテキストに変換
    static func exportAsMarkdown(tree: ThoughtTree) -> String {
        var lines: [String] = []
        lines.append("# \(tree.title)")
        lines.append("")
        for node in tree.rootNodes {
            appendMarkdown(node: node, indent: 0, to: &lines)
        }
        return lines.joined(separator: "\n")
    }

    private static func appendMarkdown(
        node: ThoughtNode,
        indent: Int,
        to lines: inout [String]
    ) {
        let prefix = String(repeating: "  ", count: indent)
        lines.append("\(prefix)- \(node.text)")
        if let note = node.note, !note.isEmpty {
            for noteLine in note.components(separatedBy: .newlines) {
                lines.append("\(prefix)  > \(noteLine)")
            }
        }
        for child in node.sortedChildren {
            appendMarkdown(node: child, indent: indent + 1, to: &lines)
        }
    }
}
