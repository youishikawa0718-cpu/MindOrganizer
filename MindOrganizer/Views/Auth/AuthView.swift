import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    @Environment(\.dismiss) private var dismiss
    private let authRepository = AuthRepository()

    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // App Icon & Title
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 64))
                        .foregroundStyle(.tint)
                    Text("マインド整理")
                        .font(.largeTitle.bold())
                    Text("思考を構造化して\n頭の中をスッキリさせよう")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Sign-In Buttons
                VStack(spacing: 16) {
                    // Apple Sign-In
                    SignInWithAppleButton(.signIn) { request in
                        do {
                            try authRepository.prepareAppleSignInRequest(request)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 50)

                    // Google Sign-In
                    Button {
                        signInWithGoogle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Googleでサインイン")
                                .font(.body.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }

                // Guest Mode
                Button {
                    dismiss()
                } label: {
                    Text("ログインせずに始める")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Text("ログインするとデバイス間でデータを同期できます")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom)
            }
            .padding(.horizontal, 32)
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
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
