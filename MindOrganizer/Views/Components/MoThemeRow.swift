import SwiftUI

struct MoThemeRow: View {
    let tree: ThoughtTree

    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private var railColor: Color {
        if let hex = tree.colorHex { Color(hex: hex) }
        else if let tag = tree.tags.first { Color(hex: tag.colorHex) }
        else { Color.moAccent(accentKey) }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(railColor)
                .frame(width: 2, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(tree.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.moInk)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("\(tree.nodes.count) nodes")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.moInkFaint)

                    if let tag = tree.tags.first {
                        Text("·")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.moInkFaint)
                        MoChip(label: tag.name, color: Color(hex: tag.colorHex), mini: true)
                    }

                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.moInkFaint)
                    Text(tree.updatedAt.relativeDisplay)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.moInkFaint)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.moInkFaint)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
