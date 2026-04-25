import SwiftUI

enum OnboardingVisual: Int, CaseIterable {
    case tree
    case indent
    case radial

    var view: AnyView {
        switch self {
        case .tree:   AnyView(TreeVisual())
        case .indent: AnyView(IndentVisual())
        case .radial: AnyView(RadialVisual())
        }
    }
}

private struct TreeVisual: View {
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    var body: some View {
        Canvas { context, size in
            let accent = Color.moAccent(accentKey)
            let ink = Color.moInk.opacity(0.7)
            let hair = Color.moHairStrong

            let rootX = size.width / 2
            let rootY = size.height * 0.28
            let trunkBottomY = size.height * 0.82

            var trunk = Path()
            trunk.move(to: CGPoint(x: rootX, y: rootY))
            trunk.addLine(to: CGPoint(x: rootX, y: trunkBottomY))
            context.stroke(trunk, with: .color(hair), lineWidth: 1.2)

            let branches: [(CGFloat, CGFloat)] = [
                (-70, 0.55),
                (70, 0.55),
                (-50, 0.72),
                (50, 0.72),
            ]

            for branch in branches {
                let bx = branch.0
                let by = size.height * branch.1
                var path = Path()
                path.move(to: CGPoint(x: rootX, y: by))
                path.addQuadCurve(
                    to: CGPoint(x: rootX + bx, y: by - 30),
                    control: CGPoint(x: rootX + bx * 0.4, y: by - 5)
                )
                context.stroke(path, with: .color(hair), lineWidth: 1.2)

                let nodeRect = CGRect(x: rootX + bx - 4, y: by - 34, width: 8, height: 8)
                context.fill(Path(ellipseIn: nodeRect), with: .color(ink))
            }

            let rootRect = CGRect(x: rootX - 12, y: rootY - 12, width: 24, height: 24)
            context.fill(Path(ellipseIn: rootRect), with: .color(accent))
            context.stroke(
                Path(ellipseIn: rootRect.insetBy(dx: -5, dy: -5)),
                with: .color(accent.opacity(0.15)),
                lineWidth: 5
            )
        }
        .frame(width: 240, height: 240)
        .accessibilityHidden(true)
    }
}

private struct IndentVisual: View {
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private let lines: [(indent: Int, width: CGFloat)] = [
        (0, 0.80),
        (1, 0.65),
        (1, 0.55),
        (2, 0.45),
        (2, 0.50),
        (1, 0.62),
        (0, 0.75),
    ]

    var body: some View {
        Canvas { context, size in
            let accent = Color.moAccent(accentKey)
            let ink = Color.moInk.opacity(0.45)
            let hair = Color.moHair

            let startY: CGFloat = 32
            let rowHeight: CGFloat = 24
            let indentStep: CGFloat = 22
            let leftPad: CGFloat = 20

            for (i, line) in lines.enumerated() {
                let y = startY + CGFloat(i) * rowHeight
                let x = leftPad + CGFloat(line.indent) * indentStep

                for d in 0..<line.indent {
                    let gx = leftPad + CGFloat(d) * indentStep + 4
                    var guide = Path()
                    guide.move(to: CGPoint(x: gx, y: y - 2))
                    guide.addLine(to: CGPoint(x: gx, y: y + rowHeight - 2))
                    context.stroke(guide, with: .color(hair), lineWidth: 0.5)
                }

                let dotRect = CGRect(x: x, y: y + 6, width: 5, height: 5)
                context.fill(Path(ellipseIn: dotRect), with: .color(i == 3 ? accent : ink))

                let lineWidth = (size.width - x - 20) * line.width
                let lineRect = CGRect(x: x + 12, y: y + 7, width: lineWidth, height: 3)
                context.fill(
                    Path(roundedRect: lineRect, cornerRadius: 1.5),
                    with: .color(i == 3 ? accent.opacity(0.7) : ink.opacity(0.6))
                )
            }
        }
        .frame(width: 240, height: 240)
        .accessibilityHidden(true)
    }
}

private struct RadialVisual: View {
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    var body: some View {
        Canvas { context, size in
            let accent = Color.moAccent(accentKey)
            let ink = Color.moInk.opacity(0.7)
            let hair = Color.moHairStrong

            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius: CGFloat = 80
            let count = 6

            for i in 0..<count {
                let angle = (Double(i) / Double(count)) * 2 * .pi - .pi / 2
                let px = center.x + cos(angle) * radius
                let py = center.y + sin(angle) * radius

                var line = Path()
                line.move(to: center)
                line.addLine(to: CGPoint(x: px, y: py))
                context.stroke(line, with: .color(hair), lineWidth: 1)

                let nodeRect = CGRect(x: px - 7, y: py - 7, width: 14, height: 14)
                context.fill(Path(ellipseIn: nodeRect), with: .color(Color.moBgElev))
                context.stroke(Path(ellipseIn: nodeRect), with: .color(ink), lineWidth: 1)
            }

            let rootRect = CGRect(x: center.x - 18, y: center.y - 18, width: 36, height: 36)
            context.stroke(
                Path(ellipseIn: rootRect.insetBy(dx: -8, dy: -8)),
                with: .color(accent.opacity(0.12)),
                lineWidth: 6
            )
            context.fill(Path(ellipseIn: rootRect), with: .color(accent))
        }
        .frame(width: 240, height: 240)
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack {
        OnboardingVisual.tree.view
        OnboardingVisual.indent.view
        OnboardingVisual.radial.view
    }
    .padding()
    .background(Color.moBg)
}
