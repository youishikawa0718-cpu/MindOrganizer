import Foundation

@MainActor
protocol ThoughtSyncing {
    func fetchTrees() async throws -> [ThoughtTreeDTO]
    func saveTree(_ tree: ThoughtTree) async throws
    func deleteTree(_ treeId: String) async throws
    func fetchTags() async throws -> [(id: String, name: String, colorHex: String)]
    func saveTag(id: String, name: String, colorHex: String) async throws
    func deleteTag(_ tagId: String) async throws
}
