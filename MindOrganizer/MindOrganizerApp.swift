import SwiftUI
import SwiftData
import FirebaseCore

@main
struct MindOrganizerApp: App {
    @State private var appState: AppState
    @AppStorage("appearance") private var appearance = Appearance.system

    init() {
        FirebaseApp.configure()
        _appState = State(initialValue: AppState())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(appearance.colorScheme)
        }
        .modelContainer(SharedModelContainer.container)
    }
}
