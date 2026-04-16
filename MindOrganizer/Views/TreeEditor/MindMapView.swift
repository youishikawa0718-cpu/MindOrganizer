import SwiftUI

/// 放射状マインドマップ表示
struct MindMapView: View {
    let tree: ThoughtTree
    let onEditNode: (ThoughtNode) -> Void
    let onToggleCollapse: (ThoughtNode) -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let layoutEngine = MindMapLayoutEngine()

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let layouts = layoutEngine.layout(rootNodes: tree.rootNodes, center: center)
            let nodeMap = Dictionary(
                tree.nodes.map { ($0.id, $0) },
                uniquingKeysWith: { first, _ in first }
            )
            let layoutMap = Dictionary(
                layouts.map { ($0.nodeId, $0) },
                uniquingKeysWith: { first, _ in first }
            )

            ZStack {
                // 接続線の描画
                Canvas { context, _ in
                    for layout in layouts {
                        guard let parentId = layout.parentId,
                              let parentLayout = layoutMap[parentId] else { continue }

                        let from = transformedPoint(parentLayout.position, center: center)
                        let to = transformedPoint(layout.position, center: center)

                        var path = Path()
                        // ベジェ曲線で接続
                        let midX = (from.x + to.x) / 2
                        path.move(to: from)
                        path.addCurve(
                            to: to,
                            control1: CGPoint(x: midX, y: from.y),
                            control2: CGPoint(x: midX, y: to.y)
                        )

                        context.stroke(
                            path,
                            with: .color(.secondary.opacity(0.4)),
                            lineWidth: 1.5
                        )
                    }
                }

                // ノードの描画
                ForEach(layouts, id: \.nodeId) { layout in
                    if let node = nodeMap[layout.nodeId] {
                        let pos = transformedPoint(layout.position, center: center)
                        MindMapNodeView(
                            node: node,
                            isRoot: node.parent == nil,
                            onTap: { onEditNode(node) },
                            onToggleCollapse: { onToggleCollapse(node) }
                        )
                        .position(pos)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .gesture(magnifyGesture)
        }
    }

    // MARK: - Transform

    private func transformedPoint(_ point: CGPoint, center: CGPoint) -> CGPoint {
        CGPoint(
            x: (point.x - center.x) * scale + center.x + offset.width,
            y: (point.y - center.y) * scale + center.y + offset.height
        )
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                scale = min(max(newScale, 0.3), 3.0)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
}
