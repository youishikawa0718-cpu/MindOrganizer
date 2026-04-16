import Foundation

/// 放射状ツリーレイアウトの計算結果
struct NodeLayout {
    let nodeId: UUID
    let position: CGPoint
    let parentId: UUID?
}

/// ルートを中心に子ノードを放射状に配置するレイアウトエンジン
struct MindMapLayoutEngine {
    /// 階層ごとの半径増分
    var radiusStep: CGFloat = 160
    /// 最小角度幅（ラジアン）— ノードが密集しすぎないための下限
    var minAngleSpan: CGFloat = .pi / 12

    /// ツリー全体のレイアウトを計算
    /// - Parameters:
    ///   - rootNodes: ルートノード配列（sortOrder順）
    ///   - center: ルートの中心座標
    /// - Returns: 全ノードのレイアウト配列
    func layout(rootNodes: [ThoughtNode], center: CGPoint) -> [NodeLayout] {
        guard !rootNodes.isEmpty else { return [] }

        var results: [NodeLayout] = []

        if rootNodes.count == 1 {
            // ルートが1つ → 中心に配置し、子を全周に展開
            let root = rootNodes[0]
            results.append(NodeLayout(nodeId: root.id, position: center, parentId: nil))
            let children = visibleChildren(of: root)
            layoutChildren(
                children,
                parentId: root.id,
                parentPosition: center,
                angleStart: 0,
                angleEnd: 2 * .pi,
                depth: 1,
                results: &results
            )
        } else {
            // 複数ルート → 仮想中心を置き、ルートを全周に均等配置
            let angleStep = (2 * CGFloat.pi) / CGFloat(rootNodes.count)
            for (i, root) in rootNodes.enumerated() {
                let angle = angleStep * CGFloat(i) - .pi / 2
                let pos = CGPoint(
                    x: center.x + radiusStep * cos(angle),
                    y: center.y + radiusStep * sin(angle)
                )
                results.append(NodeLayout(nodeId: root.id, position: pos, parentId: nil))

                let children = visibleChildren(of: root)
                let halfSpan = angleStep / 2
                layoutChildren(
                    children,
                    parentId: root.id,
                    parentPosition: pos,
                    angleStart: angle - halfSpan,
                    angleEnd: angle + halfSpan,
                    depth: 2,
                    results: &results
                )
            }
        }

        return results
    }

    // MARK: - Private

    private func layoutChildren(
        _ children: [ThoughtNode],
        parentId: UUID,
        parentPosition: CGPoint,
        angleStart: CGFloat,
        angleEnd: CGFloat,
        depth: Int,
        results: inout [NodeLayout]
    ) {
        guard !children.isEmpty else { return }

        let radius = radiusStep * CGFloat(depth)
        let totalAngle = angleEnd - angleStart

        // 各子のサブツリーサイズに応じて角度を按分
        let weights = children.map { CGFloat(visibleSubtreeSize(of: $0)) }
        let totalWeight = weights.reduce(0, +)

        var currentAngle = angleStart

        for (i, child) in children.enumerated() {
            let proportion = totalWeight > 0 ? weights[i] / totalWeight : 1.0 / CGFloat(children.count)
            let span = max(totalAngle * proportion, minAngleSpan)
            let midAngle = currentAngle + span / 2

            let pos = CGPoint(
                x: parentPosition.x + radius * cos(midAngle),
                y: parentPosition.y + radius * sin(midAngle)
            )
            results.append(NodeLayout(nodeId: child.id, position: pos, parentId: parentId))

            let grandchildren = visibleChildren(of: child)
            layoutChildren(
                grandchildren,
                parentId: child.id,
                parentPosition: pos,
                angleStart: currentAngle,
                angleEnd: currentAngle + span,
                depth: 1,
                results: &results
            )

            currentAngle += span
        }
    }

    /// 折りたたみを考慮した子ノード取得
    private func visibleChildren(of node: ThoughtNode) -> [ThoughtNode] {
        guard !node.isCollapsed else { return [] }
        return node.sortedChildren
    }

    /// サブツリー内の表示ノード数（自身含む）
    private func visibleSubtreeSize(of node: ThoughtNode) -> Int {
        guard !node.isCollapsed else { return 1 }
        return 1 + node.sortedChildren.reduce(0) { $0 + visibleSubtreeSize(of: $1) }
    }
}
