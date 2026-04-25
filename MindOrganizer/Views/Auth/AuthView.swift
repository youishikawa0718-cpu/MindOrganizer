import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private let authRepository = AuthRepository()

    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    header

                    Spacer()

                    signInButtons
                        .padding(.horizontal, 28)

                    guestButton
                        .padding(.top, 20)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.moDanger)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .padding(.top, 12)
                    }

                    Text("ログインするとデバイス間でデータを同期できます。")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.moInkFaint)
                        .padding(.top, 20)
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, 32)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("あとで")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.moInkMuted)
                    }
                }
            }
            .toolbarBackground(Color.moBg, for: .navigationBar)
            .overlay {
                if isLoading {
                    ZStack {
                        Color.moBg.opacity(0.6).ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(Color.moInk)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 20) {
            brainIcon

            VStack(spacing: 10) {
                MoKicker(text: "Welcome")
                Text("ようこそ、\n思考の整理場所へ。")
                    .font(.system(size: 32, weight: .bold))
                    .kerning(-0.6)
                    .foregroundStyle(Color.moInk)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
    }

    private var brainIcon: some View {
        Canvas { context, size in
            let accent = Color.moAccent(accentKey)
            let ink = Color.moInk.opacity(0.8)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - 22, y: center.y - 22, width: 44, height: 44)),
                with: .color(ink),
                lineWidth: 1.2
            )

            for i in 0..<3 {
                let angle = Double(i) * 2 * .pi / 3 - .pi / 2
                let tip = CGPoint(
                    x: center.x + cos(angle) * 16,
                    y: center.y + sin(angle) * 16
                )
                var path = Path()
                path.move(to: center)
                path.addLine(to: tip)
                context.stroke(path, with: .color(ink), lineWidth: 1.2)

                let dotRect = CGRect(x: tip.x - 3, y: tip.y - 3, width: 6, height: 6)
                context.fill(Path(ellipseIn: dotRect), with: .color(ink))
            }

            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10)),
                with: .color(accent)
            )
        }
        .frame(width: 48, height: 48)
        .accessibilityHidden(true)
    }

    private var signInButtons: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(.signIn) { request in
                do {
                    try authRepository.prepareAppleSignInRequest(request)
                } catch {
                    errorMessage = error.localizedDescription
                }
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button {
                signInWithGoogle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.moInk)
                    Text("Googleでサインイン")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.moInk)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.moBgElev)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.moHairStrong, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var guestButton: some View {
        Button {
            dismiss()
        } label: {
            Text("ログインせずに始める")
                .font(.system(size: 14))
                .foregroundStyle(Color.moInkMuted)
                .underline()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let authorization = try result.get()
                try await authRepository.handleAppleSignIn(authorization: authorization)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func signInWithGoogle() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await authRepository.signInWithGoogle()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
