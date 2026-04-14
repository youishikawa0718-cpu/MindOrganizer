import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class RemoteThoughtRepository: ThoughtSyncing {
    private let db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    private func userCollection(_ collection: String) throws -> CollectionReference {
        guard let userId else { throw AuthError.notAuthenticated }
        return db.collection("users").document(userId).collection(collection)
    }

    // MARK: - Trees

    func fetchTrees() async throws -> [ThoughtTreeDTO] {
        let snapshot = try await userCollection("trees").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ThoughtTreeDTO.self)
        }
    }

    func saveTree(_ tree: ThoughtTree) async throws {
        let dto = ThoughtTreeDTO(from: tree)
        try await userCollection("trees")
            .document(tree.id.uuidString)
            .setData(dto.toDict(), merge: true)
    }

    func deleteTree(_ treeId: String) async throws {
        try await userCollection("trees").document(treeId).delete()
    }

    // MARK: - Tags

    func fetchTags() async throws -> [(id: String, name: String, colorHex: String)] {
        let snapshot = try await userCollection("tags").getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let colorHex = data["colorHex"] as? String else { return nil }
            return (id: doc.documentID, name: name, colorHex: colorHex)
        }
    }

    func saveTag(id: String, name: String, colorHex: String) async throws {
        try await userCollection("tags").document(id).setData([
            "name": name,
            "colorHex": colorHex,
        ], merge: true)
    }

    func deleteTag(_ tagId: String) async throws {
        try await userCollection("tags").document(tagId).delete()
    }

    // MARK: - Bulk Delete (Account Deletion)

    func deleteAllUserData() async throws {
        guard let userId else { throw AuthError.notAuthenticated }
        let userDoc = db.collection("users").document(userId)

        // Delete trees subcollection
        let trees = try await userDoc.collection("trees").getDocuments()
        for doc in trees.documents {
            try await doc.reference.delete()
        }

        // Delete tags subcollection
        let tags = try await userDoc.collection("tags").getDocuments()
        for doc in tags.documents {
            try await doc.reference.delete()
        }

        // Delete snapshots subcollection
        let snapshots = try await userDoc.collection("snapshots").getDocuments()
        for doc in snapshots.documents {
            try await doc.reference.delete()
        }

        // Delete user document
        try await userDoc.delete()
    }
}
