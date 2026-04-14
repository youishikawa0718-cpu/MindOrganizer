import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            HomeView()
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
