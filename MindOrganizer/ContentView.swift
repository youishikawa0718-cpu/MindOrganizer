import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            ThoughtTree.self,
            ThoughtNode.self,
            Tag.self,
            Snapshot.self,
        ], inMemory: true)
}
