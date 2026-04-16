import SwiftUI

/// マインドマップ上の個別ノード表示
struct MindMapNodeView: View {
    let node: ThoughtNode
    let isRoot: Bool
    let onTap: () -> Void
    let onToggleCollapse: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            Text(node.text)
                .font(isRoot ? .headline : .subheadline)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if node.isCollapsed && !node.children.isEmpty {
                Text("+\(node.children.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, isRoot ? 16 : 10)
        .padding(.vertical, isRoot ? 10 : 6)
        .background(backgroundStyle)
        .clipShape(RoundedRectangle(cornerRadius: isRoot ? 12 : 8))
        .overlay(
            RoundedRectangle(cornerRadius: isRoot ? 12 : 8)
                .stroke(borderColor, lineWidth: isRoot ? 2 : 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        .onTapGesture { onTap() }
        .onLongPressGesture { onToggleCollapse() }
    }

    private var backgroundStyle: some ShapeStyle {
        isRoot
            ? AnyShapeStyle(.tint.opacity(0.15))
            : AnyShapeStyle(.background)
    }

    private var borderColor: Color {
        isRoot ? .accentColor : .secondary.opacity(0.3)
    }
}
