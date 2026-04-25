import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("accentKey") private var accentKey: String = "indigo"

    @State private var searchText = ""
    @State private var filter: SearchFilter = .all
    @State private var results: [SearchHit] = []

    private var accent: Color { Color.moAccent(accentKey) }

    var body: some View {
        ZStack {
            Color.moBg.ignoresSafeArea()

            VStack(spacing: 0) {
                searchField
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                filterChips
                    .padding(.bottom, 8)

                if searchText.isEmpty {
                    hintState
                } else if results.isEmpty {
                    noResultsState
                } else {
                    resultsList
                }
            }
        }
        .navigationTitle("検索")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.moBg, for: .navigationBar)
        .onChange(of: searchText) { performSearch() }
        .onChange(of: filter) { performSearch() }
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.moInkFaint)
            TextField("テーマ・ノード・メモを検索", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Color.moInk)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.moInkFaint)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule().fill(Color.moBgElev2)
        )
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SearchFilter.allCases) { f in
                    filterChip(f)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func filterChip(_ f: SearchFilter) -> some View {
        let isSelected = filter == f
        return Button {
            filter = f
        } label: {
            Text(f.label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? Color.moBg : Color.moInkMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isSelected ? Color.moInk : Color.moBgElev2)
                )
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? Color.clear : Color.moHair,
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Results

    private var resultsList: some View {
        List {
            Section {
                ForEach(results) { hit in
                    NavigationLink {
                        TreeEditorView(tree: hit.tree)
                    } label: {
                        resultRow(hit)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .listRowBackground(Color.moBg)
                    .listRowSeparatorTint(Color.moHair)
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    MoKicker(text: "\(results.count) Results")
                    Text("検索結果")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.moInk)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .listRowInsets(EdgeInsets())
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.moBg)
    }

    private func resultRow(_ hit: SearchHit) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(highlighted(hit.tree.title, query: searchText))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.moInk)
                .lineLimit(1)

            if !hit.nodeMatches.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(hit.nodeMatches.prefix(3).enumerated()), id: \.offset) { _, match in
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle()
                                .fill(Color.moHairStrong)
                                .frame(width: 2)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(highlighted(match.text, query: searchText))
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.moInkMuted)
                                    .lineLimit(1)
                                if match.isNote {
                                    Text("MEMO")
                                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                                        .tracking(1.5)
                                        .foregroundStyle(Color.moInkFaint)
                                }
                            }
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                Text(hit.tree.updatedAt.relativeDisplay)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.moInkFaint)
                ForEach(hit.tree.tags) { tag in
                    MoChip(label: tag.name, color: Color(hex: tag.colorHex), mini: true)
                }
            }
        }
    }

    // MARK: - States

    private var hintState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(Color.moInkFaint)
            Text("キーワードで検索")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.moInk)
            Text("テーマ名・ノード・メモから\n一致するものを探します")
                .font(.system(size: 13))
                .foregroundStyle(Color.moInkMuted)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var noResultsState: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("一致する結果はありません")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.moInk)
            Text("別のキーワードを試してみてください")
                .font(.system(size: 12))
                .foregroundStyle(Color.moInkMuted)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Highlight

    private func highlighted(_ string: String, query: String) -> AttributedString {
        var attr = AttributedString(string)
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return attr }

        var searchRange = attr.startIndex..<attr.endIndex
        while let range = attr[searchRange].range(of: trimmedQuery, options: .caseInsensitive) {
            attr[range].foregroundColor = accent
            attr[range].backgroundColor = accent.opacity(0.13)
            searchRange = range.upperBound..<attr.endIndex
        }
        return attr
    }

    // MARK: - Search

    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            results = []
            return
        }

        let descriptor = FetchDescriptor<ThoughtTree>(
            sortBy: [SortDescriptor(\ThoughtTree.updatedAt, order: .reverse)]
        )

        do {
            let allTrees = try modelContext.fetch(descriptor)
            results = allTrees.compactMap { tree -> SearchHit? in
                let titleMatch = tree.title.localizedCaseInsensitiveContains(query)

                var nodeMatches: [NodeMatch] = []
                for node in tree.nodes {
                    let textMatch = node.text.localizedCaseInsensitiveContains(query)
                    let noteMatch = node.note?.localizedCaseInsensitiveContains(query) ?? false

                    switch filter {
                    case .all:
                        if textMatch { nodeMatches.append(NodeMatch(nodeId: node.id, text: node.text, isNote: false)) }
                        if noteMatch, let note = node.note {
                            nodeMatches.append(NodeMatch(nodeId: node.id, text: note, isNote: true))
                        }
                    case .theme:
                        break
                    case .node:
                        if textMatch { nodeMatches.append(NodeMatch(nodeId: node.id, text: node.text, isNote: false)) }
                    case .note:
                        if noteMatch, let note = node.note {
                            nodeMatches.append(NodeMatch(nodeId: node.id, text: note, isNote: true))
                        }
                    }
                }

                let includesTree: Bool
                switch filter {
                case .all:   includesTree = titleMatch || !nodeMatches.isEmpty
                case .theme: includesTree = titleMatch
                case .node, .note: includesTree = !nodeMatches.isEmpty
                }

                guard includesTree else { return nil }
                return SearchHit(tree: tree, nodeMatches: nodeMatches)
            }
        } catch {
            results = []
        }
    }
}

enum SearchFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case theme
    case node
    case note

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: "すべて"
        case .theme: "テーマ"
        case .node: "ノード"
        case .note: "メモ"
        }
    }
}

struct SearchHit: Identifiable {
    let tree: ThoughtTree
    let nodeMatches: [NodeMatch]
    var id: UUID { tree.id }
}

struct NodeMatch {
    let nodeId: UUID
    let text: String
    let isNote: Bool
}
