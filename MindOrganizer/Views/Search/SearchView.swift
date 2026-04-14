import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var results: [ThoughtTree] = []

    var body: some View {
        List {
            if results.isEmpty && !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ForEach(results) { tree in
                    NavigationLink {
                        TreeEditorView(tree: tree)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tree.title)
                                .font(.headline)
                            let matchingNodes = tree.nodes.filter {
                                $0.text.localizedCaseInsensitiveContains(searchText)
                            }
                            if !matchingNodes.isEmpty {
                                ForEach(matchingNodes.prefix(3)) { node in
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.turn.down.right")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                        Text(node.text)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            HStack(spacing: 6) {
                                Text(tree.updatedAt.relativeDisplay)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                                ForEach(tree.tags) { tag in
                                    TagChip(tag: tag, style: .compact)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("検索")
        .searchable(text: $searchText, prompt: "テーマ・ノードを検索")
        .onChange(of: searchText) {
            performSearch()
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else {
            results = []
            return
        }

        let query = searchText
        let descriptor = FetchDescriptor<ThoughtTree>(
            sortBy: [SortDescriptor(\ThoughtTree.updatedAt, order: .reverse)]
        )

        do {
            let allTrees = try modelContext.fetch(descriptor)
            results = allTrees.filter { tree in
                tree.title.localizedCaseInsensitiveContains(query) ||
                tree.nodes.contains { $0.text.localizedCaseInsensitiveContains(query) }
            }
        } catch {
            results = []
        }
    }
}
