import SwiftUI

struct EmptyNodeStateView: View {
    let onAddNode: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("ノードがありません", systemImage: "text.badge.plus")
        } description: {
            Text("最初のノードを追加して\n思考を整理しましょう")
        } actions: {
            Button("ノードを追加") {
                onAddNode()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
