import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("accentKey") private var accentKey: String = "indigo"
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            visual: .tree,
            title: "頭の中を、\n整える。",
            description: "モヤモヤを言葉にして、\nツリーの上に置いていく。"
        ),
        OnboardingPage(
            visual: .indent,
            title: "自由に、\n深く、組み替える。",
            description: "ノードを足して、並べ替えて、\nインデントで関係を描く。"
        ),
        OnboardingPage(
            visual: .radial,
            title: "全体を、\n俯瞰する。",
            description: "マインドマップに切り替えれば、\n思考の地図が一目で見える。"
        ),
    ]

    var body: some View {
        ZStack {
            Color.moBg.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageView(pages[index], index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                dotsIndicator

                primaryButton
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                skipRow
                    .padding(.top, 16)
                    .padding(.bottom, 28)
            }
        }
    }

    private func pageView(_ page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 16)

            page.visual.view

            VStack(spacing: 12) {
                MoKicker(text: "0\(index + 1) — Step \(index + 1) of \(pages.count)")

                Text(page.title)
                    .font(.system(size: 34, weight: .bold))
                    .kerning(-0.8)
                    .foregroundStyle(Color.moInk)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(page.description)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.moInkMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.top, 4)
            }

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 32)
    }

    private var dotsIndicator: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Color.moInk : Color.moInkUltra)
                    .frame(width: i == currentPage ? 24 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private var primaryButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation { currentPage += 1 }
            } else {
                hasCompletedOnboarding = true
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "次へ" : "はじめる")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.moBg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.moInk)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var skipRow: some View {
        if currentPage < pages.count - 1 {
            Button {
                hasCompletedOnboarding = true
            } label: {
                Text("スキップ")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.moInkMuted)
            }
            .buttonStyle(.plain)
        } else {
            Color.clear.frame(height: 16)
        }
    }
}

private struct OnboardingPage {
    let visual: OnboardingVisual
    let title: String
    let description: String
}
