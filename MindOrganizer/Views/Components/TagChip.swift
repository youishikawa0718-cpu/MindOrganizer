import SwiftUI

enum TagChipStyle {
    case compact
    case regular
}

struct TagChip: View {
    let tag: Tag
    var style: TagChipStyle = .regular

    var body: some View {
        Text(tag.name)
            .font(style == .compact ? .caption2 : .caption)
            .padding(.horizontal, style == .compact ? 6 : 8)
            .padding(.vertical, style == .compact ? 2 : 4)
            .background(Color(hex: tag.colorHex).opacity(0.2))
            .foregroundStyle(Color(hex: tag.colorHex))
            .clipShape(Capsule())
    }
}
