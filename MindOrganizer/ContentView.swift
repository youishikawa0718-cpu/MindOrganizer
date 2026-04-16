import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView()
        } else {
            NavigationStack {
                HomeView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .modelContainer(for: [
            ThoughtTree.self,
            ThoughtNode.self,
            Tag.self,
            Snapshot.self,
        ], inMemory: true)
}
