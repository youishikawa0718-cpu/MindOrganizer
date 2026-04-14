import Foundation
import SwiftData
import Observation
import Network
import FirebaseAuth

@Observable
@MainActor
final class SyncService {
    var isSyncing = false
    var lastSyncedAt: Date?
    var syncError: String?

    private let remoteRepo = RemoteThoughtRepository()
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.mindorganizer.network")
    private var isNetworkAvailable = false
    private var pendingSyncModelContext: ModelContext?

    init() {
        startNetworkMonitoring()
    }

    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                let wasAvailable = self?.isNetworkAvailable ?? false
                self?.isNetworkAvailable = path.status == .satisfied
                if !wasAvailable && path.status == .satisfied {
                    await self?.syncIfNeeded()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Sync

    func syncAll(modelContext: ModelContext) async {
        guard isAuthenticated, isNetworkAvailable else { return }
        guard !isSyncing else { return }

        isSyncing = true
        syncError = nil
        defer { isSyncing = false }

        do {
            try await pushLocalChanges(modelContext: modelContext)
            try await pullRemoteChanges(modelContext: modelContext)
            lastSyncedAt = Date()
        } catch {
            syncError = error.localizedDescription
        }
    }

    // MARK: - Push Local → Remote

    private func pushLocalChanges(modelContext: ModelContext) async throws {
        let descriptor = FetchDescriptor<ThoughtTree>()
        let trees = try modelContext.fetch(descriptor)

        for tree in trees {
            try await remoteRepo.saveTree(tree)
        }

        // Push tags
        let tagDescriptor = FetchDescriptor<Tag>()
        let tags = try modelContext.fetch(tagDescriptor)
        for tag in tags {
            try await remoteRepo.saveTag(
                id: tag.id.uuidString,
                name: tag.name,
                colorHex: tag.colorHex
            )
        }
    }

    // MARK: - Pull Remote → Local

    private func pullRemoteChanges(modelContext: ModelContext) async throws {
        let remoteTrees = try await remoteRepo.fetchTrees()
        let localDescriptor = FetchDescriptor<ThoughtTree>()
        let localTrees = try modelContext.fetch(localDescriptor)
        let localTreeIds = Set(localTrees.map { $0.id.uuidString })

        for remoteTree in remoteTrees {
            if !localTreeIds.contains(remoteTree.id) {
                // リモートにあってローカルにない → ローカルに追加
                let tree = ThoughtTree(title: remoteTree.title)
                tree.isPinned = remoteTree.isPinned
                tree.colorHex = remoteTree.colorHex
                tree.createdAt = remoteTree.createdAt
                tree.updatedAt = remoteTree.updatedAt
                modelContext.insert(tree)

                // ノードを再構築
                rebuildNodes(from: remoteTree.nodes, into: tree, modelContext: modelContext)
            } else if let localTree = localTrees.first(where: { $0.id.uuidString == remoteTree.id }) {
                // 両方に存在 → updatedAtが新しい方を採用
                if remoteTree.updatedAt > localTree.updatedAt {
                    localTree.title = remoteTree.title
                    localTree.isPinned = remoteTree.isPinned
                    localTree.colorHex = remoteTree.colorHex
                    localTree.updatedAt = remoteTree.updatedAt

                    // ノードを再構築
                    for node in localTree.nodes {
                        modelContext.delete(node)
                    }
                    rebuildNodes(from: remoteTree.nodes, into: localTree, modelContext: modelContext)
                }
            }
        }

        // Pull tags
        let remoteTags = try await remoteRepo.fetchTags()
        let localTagDescriptor = FetchDescriptor<Tag>()
        let localTags = try modelContext.fetch(localTagDescriptor)
        let localTagIds = Set(localTags.map { $0.id.uuidString })

        for remoteTag in remoteTags {
            if !localTagIds.contains(remoteTag.id) {
                if let uuid = UUID(uuidString: remoteTag.id) {
                    let tag = Tag(name: remoteTag.name, colorHex: remoteTag.colorHex)
                    // Replace the auto-generated UUID
                    tag.id = uuid
                    modelContext.insert(tag)
                }
            }
        }
    }

    private func rebuildNodes(
        from dtos: [ThoughtNodeDTO],
        into tree: ThoughtTree,
        modelContext: ModelContext
    ) {
        // First pass: create all nodes
        var nodeMap: [String: ThoughtNode] = [:]
        for dto in dtos {
            let node = ThoughtNode(
                text: dto.text,
                note: dto.note,
                sortOrder: dto.sortOrder,
                depth: dto.depth,
                tree: tree
            )
            node.isCollapsed = dto.isCollapsed
            node.createdAt = dto.createdAt
            node.updatedAt = dto.updatedAt
            if let uuid = UUID(uuidString: dto.id) {
                node.id = uuid
            }
            modelContext.insert(node)
            nodeMap[dto.id] = node
        }

        // Second pass: set parent relationships
        for dto in dtos {
            guard let parentId = dto.parentId,
                  let child = nodeMap[dto.id],
                  let parent = nodeMap[parentId] else { continue }
            child.parent = parent
        }
    }

    // MARK: - Scheduled sync

    func setPendingContext(_ context: ModelContext) {
        pendingSyncModelContext = context
    }

    private func syncIfNeeded() async {
        guard let context = pendingSyncModelContext else { return }
        await syncAll(modelContext: context)
    }
}
