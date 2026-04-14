import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ThoughtTree.updatedAt, order: .reverse) private var trees: [ThoughtTree]
    @State private var showingNewTreeSheet = false
    @State private var newTreeTitle = ""
    @State private var searchText = ""

    private var pinnedTrees: [ThoughtTree] {
        trees.filter { $0.isPinned }
    }

    private var recentTrees: [ThoughtTree] {
        trees.filter { !$0.isPinned }
    }

    private var filteredTrees: [ThoughtTree] {
        guard !searchText.isEmpty else { return trees }
        return trees.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if trees.isEmpty {
                emptyState
            } else {
                treeList
            }
        }
        .navigationTitle("マインド整理")
        .searchable(text: $searchText, prompt: "テーマを検索")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    Button {
                        showingNewTreeSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewTreeSheet) {
            newTreeSheet
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("まだテーマがありません", systemImage: "brain.head.profile")
        } description: {
            Text("頭の中を整理してみましょう")
        } actions: {
            Button("新しいテーマを作成") {
                showingNewTreeSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Tree List

    private var treeList: some View {
        List {
            if !searchText.isEmpty {
                ForEach(filteredTrees) { tree in
                    treeRow(tree)
                }
            } else {
                if !pinnedTrees.isEmpty {
                    Section("ピン留め") {
                        ForEach(pinnedTrees) { tree in
                            treeRow(tree)
                        }
                    }
                }
                Section(pinnedTrees.isEmpty ? "テーマ" : "最近") {
                    ForEach(recentTrees) { tree in
                        treeRow(tree)
                    }
                }
            }
        }
    }

    private func treeRow(_ tree: ThoughtTree) -> some View {
        NavigationLink {
            TreeEditorView(tree: tree)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if tree.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    Text(tree.title)
                        .font(.headline)
                    Spacer()
                    Text(tree.updatedAt.relativeDisplay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    Label("\(tree.nodes.count)", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(tree.tags) { tag in
                        TagChip(tag: tag, style: .compact)
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .swipeActions(edge: .leading) {
            Button {
                tree.isPinned.toggle()
                tree.updatedAt = Date()
            } label: {
                Image(systemName: tree.isPinned ? "pin.slash" : "pin")
            }
            .tint(.orange)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                modelContext.delete(tree)
            } label: {
                Image(systemName: "trash")
            }
        }
    }

    // MARK: - New Tree Sheet

    private var newTreeSheet: some View {
        NavigationStack {
            Form {
                TextField("テーマを入力", text: $newTreeTitle)
                    .onSubmit {
                        createTree()
                    }
            }
            .navigationTitle("新しいテーマ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        newTreeTitle = ""
                        showingNewTreeSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("作成") {
                        createTree()
                    }
                    .disabled(newTreeTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func createTree() {
        let trimmed = newTreeTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let tree = ThoughtTree(title: trimmed)
        modelContext.insert(tree)
        newTreeTitle = ""
        showingNewTreeSheet = false
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: [
        ThoughtTree.self,
        ThoughtNode.self,
        Tag.self,
        Snapshot.self,
    ], inMemory: true)
}
