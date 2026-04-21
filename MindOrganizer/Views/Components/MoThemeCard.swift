import SwiftUI

struct MoThemeCard: View {
    let tree: ThoughtTree

    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private var railColor: Color {
        if let hex = tree.colorHex { Color(hex: hex) }
        else if let tag = tree.tags.first { Color(hex: tag.colorHex) }
        else { Color.moAccent(accentKey) }
    }

    private var previewNodes: [ThoughtNode] {
        tree.nodes
            .sorted { $0.sortOrder < $1.sortOrder }
            .prefix(4)
            .map { $0 }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(railColor)
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 12) {
                header
                title
                preview
                footer
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.moBgElev)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.moHair, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var header: some View {
        HStack(spacing: 6) {
            if tree.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.moPin)
            }
            MoKicker(text: tree.updatedAt.relativeDisplay)
            Spacer(minLength: 0)
        }
    }

    private var title: some View {
        Text(tree.title)
            .font(.system(size: 20, weight: .semibold))
            .kerning(-0.3)
            .foregroundStyle(Color.moInk)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    private var preview: some View {
        if previewNodes.isEmpty {
            Text("まだノードなし")
                .font(.system(size: 13))
                .foregroundStyle(Color.moInkFaint)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(previewNodes) { node in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Circle()
                            .fill(Color.moInkUltra)
                            .frame(width: 5, height: 5)
                            .padding(.leading, CGFloat(node.depth) * 10)
                        Text(node.text)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.moInkMuted)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            if let tag = tree.tags.first {
                MoChip(label: tag.name, color: Color(hex: tag.colorHex), mini: true)
            }
            Spacer(minLength: 0)
            Text("\(tree.nodes.count) nodes")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.moInkFaint)
        }
    }
}
