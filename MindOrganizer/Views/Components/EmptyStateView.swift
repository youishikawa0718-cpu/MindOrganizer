import SwiftUI

struct EmptyNodeStateView: View {
    let onAddNode: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color.moHairStrong,
                        style: StrokeStyle(lineWidth: 1, dash: [3, 5])
                    )
                    .frame(width: 120, height: 120)
                VStack(spacing: 2) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(Color.moInkFaint)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.moInkFaint)
                }
            }

            VStack(spacing: 6) {
                Text("ノードがありません")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.moInk)
                Text("最初のノードを追加して\n思考の整理を始めましょう。")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.moInkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }

            Button {
                onAddNode()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                    Text("ノードを追加")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.moBg)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .frame(minHeight: 48)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.moInk)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
        .background(Color.moBg)
    }
}
