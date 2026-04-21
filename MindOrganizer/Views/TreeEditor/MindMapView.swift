import SwiftUI

struct MindMapView: View {
    let tree: ThoughtTree
    let onEditNode: (ThoughtNode) -> Void
    let onToggleCollapse: (ThoughtNode) -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let layoutEngine = MindMapLayoutEngine()
    private let minScale: CGFloat = 0.3
    private let maxScale: CGFloat = 3.0
    private let dotSpacing: CGFloat = 24

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
                Color.moBg

                dotGrid(size: geometry.size)

                connections(layouts: layouts, layoutMap: layoutMap, center: center)

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
            .overlay(alignment: .bottomTrailing) {
                zoomPill
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Dot Grid

    private func dotGrid(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let spacing = dotSpacing * max(scale, 0.5)
            guard spacing > 4 else { return }
            let startX = offset.width.truncatingRemainder(dividingBy: spacing)
            let startY = offset.height.truncatingRemainder(dividingBy: spacing)
            let dotSize: CGFloat = 1.2

            var x = startX - spacing
            while x < canvasSize.width + spacing {
                var y = startY - spacing
                while y < canvasSize.height + spacing {
                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(Color.moHair))
                    y += spacing
                }
                x += spacing
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Connections

    private func connections(
        layouts: [NodeLayout],
        layoutMap: [UUID: NodeLayout],
        center: CGPoint
    ) -> some View {
        Canvas { context, _ in
            for layout in layouts {
                guard let parentId = layout.parentId,
                      let parentLayout = layoutMap[parentId] else { continue }

                let from = transformedPoint(parentLayout.position, center: center)
                let to = transformedPoint(layout.position, center: center)

                var path = Path()
                let midX = (from.x + to.x) / 2
                path.move(to: from)
                path.addCurve(
                    to: to,
                    control1: CGPoint(x: midX, y: from.y),
                    control2: CGPoint(x: midX, y: to.y)
                )

                context.stroke(
                    path,
                    with: .color(Color.moHairStrong),
                    lineWidth: 1.2
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Zoom Pill

    private var zoomPill: some View {
        VStack(spacing: 1) {
            zoomButton(symbol: "plus") {
                setScale(scale * 1.2)
            }
            Rectangle()
                .fill(Color.moHair)
                .frame(height: 1)
                .frame(width: 28)
            zoomButton(symbol: "minus") {
                setScale(scale / 1.2)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.moBgElev)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.moHair, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }

    private func zoomButton(symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.moInk)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(symbol == "plus" ? "拡大" : "縮小")
    }

    private func setScale(_ newScale: CGFloat) {
        let clamped = min(max(newScale, minScale), maxScale)
        if reduceMotion {
            scale = clamped
            lastScale = clamped
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                scale = clamped
                lastScale = clamped
            }
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
                scale = min(max(newScale, minScale), maxScale)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
}
