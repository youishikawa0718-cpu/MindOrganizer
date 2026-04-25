import SwiftUI

struct MoKicker: View {
    let text: String
    var tone: Tone = .faint

    enum Tone {
        case faint
        case muted
        case accent(Color)
    }

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .tracking(2)
            .foregroundStyle(foreground)
    }

    private var foreground: Color {
        switch tone {
        case .faint: .moInkFaint
        case .muted: .moInkMuted
        case .accent(let color): color
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MoKicker(text: "Recent")
        MoKicker(text: "10 nodes · 4 levels", tone: .muted)
        MoKicker(text: "Synced", tone: .accent(.moAccent("indigo")))
    }
    .padding()
    .background(Color.moBg)
}
