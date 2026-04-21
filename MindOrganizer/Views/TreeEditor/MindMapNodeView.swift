import SwiftUI

struct MindMapNodeView: View {
    let node: ThoughtNode
    let isRoot: Bool
    let onTap: () -> Void
    let onToggleCollapse: () -> Void

    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private var accent: Color { Color.moAccent(accentKey) }

    var body: some View {
        VStack(spacing: 2) {
            Text(node.text)
                .font(isRoot
                      ? .system(size: 15, weight: .semibold)
                      : .system(size: 13, weight: .medium))
                .kerning(-0.2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(isRoot ? Color.white : Color.moInk)

            if node.isCollapsed && !node.children.isEmpty {
                Text("+\(node.children.count)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(isRoot ? Color.white.opacity(0.8) : Color.moInkMuted)
            }
        }
        .padding(.horizontal, isRoot ? 18 : 12)
        .padding(.vertical, isRoot ? 12 : 8)
        .background(background)
        .overlay(border)
        .clipShape(Capsule())
        .background(haloRing)
        .shadow(color: shadowColor, radius: isRoot ? 14 : 4, y: isRoot ? 4 : 1)
        .onTapGesture { onTap() }
        .onLongPressGesture { onToggleCollapse() }
    }

    @ViewBuilder
    private var background: some View {
        if isRoot {
            Capsule().fill(accent)
        } else {
            Capsule().fill(Color.moBgElev)
        }
    }

    @ViewBuilder
    private var border: some View {
        if isRoot {
            EmptyView()
        } else {
            Capsule().strokeBorder(Color.moHair, lineWidth: 1)
        }
    }

    @ViewBuilder
    private var haloRing: some View {
        if isRoot {
            Capsule()
                .stroke(accent.opacity(0.18), lineWidth: 6)
                .blur(radius: 2)
                .padding(-6)
        }
    }

    private var shadowColor: Color {
        isRoot ? accent.opacity(0.45) : Color.black.opacity(0.06)
    }
}
