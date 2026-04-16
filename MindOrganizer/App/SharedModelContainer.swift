import Foundation
import SwiftData

enum SharedModelContainer {
    static let appGroupID = "group.com.yukiishikawa.MindOrganizer"

    static let schema = Schema([
        ThoughtTree.self,
        ThoughtNode.self,
        Tag.self,
        Snapshot.self,
    ])

    nonisolated(unsafe) static var container: ModelContainer = {
        let config: ModelConfiguration
        if let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) {
            let storeURL = url.appending(path: "MindOrganizer.store")
            config = ModelConfiguration("MindOrganizer", url: storeURL)
        } else {
            config = ModelConfiguration("MindOrganizer")
        }
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
