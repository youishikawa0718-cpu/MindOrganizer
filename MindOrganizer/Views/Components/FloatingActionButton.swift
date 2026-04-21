import SwiftUI

struct FloatingActionButton: View {
    let systemImage: String
    let action: () -> Void
    var accessibilityLabel: String = "追加"

    init(
        systemImage: String = "plus",
        accessibilityLabel: String = "追加",
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.moBg)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.moInk)
                )
                .shadow(color: .black.opacity(0.18), radius: 20, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.moBg.ignoresSafeArea()
        FloatingActionButton { }
            .padding(20)
    }
}
