import SwiftUI

struct MoStatCard: View {
    let label: String
    let value: String
    var tone: Tone = .plain

    enum Tone {
        case plain
        case accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(labelColor)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .kerning(-0.4)
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 62)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(background)
        .overlay(overlayBorder)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @Environment(\.colorScheme) private var scheme
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private var accent: Color { .moAccent(accentKey) }

    private var labelColor: Color {
        switch tone {
        case .plain: .moInkFaint
        case .accent: .white.opacity(0.75)
        }
    }

    private var valueColor: Color {
        switch tone {
        case .plain: .moInk
        case .accent: .white
        }
    }

    @ViewBuilder
    private var background: some View {
        switch tone {
        case .plain:
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.moBgElev)
        case .accent:
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accent)
        }
    }

    @ViewBuilder
    private var overlayBorder: some View {
        if tone == .plain {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.moHair, lineWidth: 1)
        }
    }
}

#Preview {
    HStack(spacing: 10) {
        MoStatCard(label: "テーマ", value: "12")
        MoStatCard(label: "ノード", value: "248")
        MoStatCard(label: "今週追加", value: "17", tone: .accent)
    }
    .padding()
    .background(Color.moBg)
}
