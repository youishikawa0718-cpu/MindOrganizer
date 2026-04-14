import SwiftUI

struct NodeRowView: View {
    let node: ThoughtNode
    let onToggleCollapse: () -> Void
    let onAddChild: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onIndent: () -> Void
    let onOutdent: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Collapse indicator
            if !node.children.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onToggleCollapse()
                    }
                } label: {
                    Image(systemName: node.isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)
                }
                .buttonStyle(.plain)
            } else {
                Circle()
                    .fill(.tertiary)
                    .frame(width: 6, height: 6)
                    .padding(.horizontal, 5)
            }

            // Node content
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

            Spacer()

            // Child count badge
            if node.isCollapsed && !node.children.isEmpty {
                Text("\(node.children.count)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.fill.tertiary)
                    .clipShape(Capsule())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .contextMenu {
            Button {
                onAddChild()
            } label: {
                Label("子ノードを追加", systemImage: "plus.circle")
            }
            Button {
                onEdit()
            } label: {
                Label("編集", systemImage: "pencil")
            }
            Divider()
            Button {
                onIndent()
            } label: {
                Label("インデント", systemImage: "arrow.right")
            }
            Button {
                onOutdent()
            } label: {
                Label("アウトデント", systemImage: "arrow.left")
            }
            .disabled(node.parent == nil)
            Divider()
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                onAddChild()
            } label: {
                Image(systemName: "plus.circle")
            }
            .tint(.blue)
        }
    }
}
