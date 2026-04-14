import SwiftUI
import SwiftData

@main
struct MindOrganizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            ThoughtTree.self,
            ThoughtNode.self,
            Tag.self,
            Snapshot.self,
        ])
    }
}
