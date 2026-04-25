import SwiftUI

struct MoChip: View {
    let label: String
    var color: Color = .moInk
    var showsDot: Bool = true
    var mini: Bool = false

    var body: some View {
        HStack(spacing: mini ? 4 : 6) {
            if showsDot {
                Circle()
                    .fill(color)
                    .frame(width: mini ? 4 : 5, height: mini ? 4 : 5)
            }
            Text(label)
                .font(.system(size: mini ? 10 : 11, weight: .medium))
                .foregroundStyle(Color.moInk)
        }
        .padding(.horizontal, mini ? 7 : 9)
        .padding(.vertical, mini ? 3 : 4)
        .background(
            Capsule()
                .fill(Color.moBgElev)
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.moHair, lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 8) {
        MoChip(label: "転職")
        MoChip(label: "優先度高", color: .moAccent("indigo"))
        MoChip(label: "WIP", color: .moAccent("sabi"), mini: true)
        MoChip(label: "3 nodes", showsDot: false, mini: true)
    }
    .padding()
    .background(Color.moBg)
}
