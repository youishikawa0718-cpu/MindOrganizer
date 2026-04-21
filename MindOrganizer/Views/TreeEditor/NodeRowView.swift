import SwiftUI

struct NodeRowView: View {
    let node: ThoughtNode
    let onToggleCollapse: () -> Void
    let onAddChild: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onIndent: () -> Void
    let onOutdent: () -> Void

    @AppStorage("accentKey") private var accentKey: String = "indigo"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var hasChildren: Bool { !node.children.isEmpty }

    var body: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: 20)

            ForEach(0..<node.depth, id: \.self) { _ in
                ZStack(alignment: .leading) {
                    Color.clear
                    Rectangle()
                        .fill(Color.moHair)
                        .frame(width: 0.5)
                        .offset(x: 4)
                }
                .frame(width: 22)
            }

            marker
                .frame(width: 16, height: 16)
                .padding(.trailing, 8)

            content

            Spacer(minLength: 0)

            if node.isCollapsed && hasChildren {
                childCountBadge
                    .padding(.trailing, 8)
            }

            Color.clear.frame(width: 16)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onEdit() }
        .contextMenu {
            Button { onAddChild() } label: {
                Label("子ノードを追加", systemImage: "plus.circle")
            }
            Button { onEdit() } label: {
                Label("編集", systemImage: "pencil")
            }
            Divider()
            Button { onIndent() } label: {
                Label("インデント", systemImage: "arrow.right")
            }
            Button { onOutdent() } label: {
                Label("アウトデント", systemImage: "arrow.left")
            }
            .disabled(node.parent == nil)
            Divider()
            Button(role: .destructive) { onDelete() } label: {
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
            .tint(Color.moAccent(accentKey))
        }
    }

    @ViewBuilder
    private var marker: some View {
        if hasChildren {
            Button {
                if reduceMotion {
                    onToggleCollapse()
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onToggleCollapse()
                    }
                }
            } label: {
                Image(systemName: node.isCollapsed ? "chevron.right" : "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.moInkMuted)
                    .frame(width: 16, height: 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(node.isCollapsed ? "子ノードを展開" : "子ノードを折りたたむ")
        } else {
            Circle()
                .fill(Color.moInkFaint)
                .frame(width: 5, height: 5)
                .accessibilityHidden(true)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(node.text)
                .font(.system(size: 17, weight: .regular))
                .kerning(-0.2)
                .foregroundStyle(Color.moInk)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            if let note = node.note, !note.isEmpty {
                noteView(note)
                    .padding(.top, 4)
            }
        }
    }

    private func noteView(_ note: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(Color.moHair)
                .frame(width: 2)
            Text(note)
                .font(.system(size: 12.5, weight: .regular))
                .italic()
                .foregroundStyle(Color.moInkMuted)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var childCountBadge: some View {
        Text("\(node.children.count)")
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundStyle(Color.moInkMuted)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(Color.moBgElev2)
            )
            .overlay(
                Capsule().strokeBorder(Color.moHair, lineWidth: 1)
            )
    }
}
