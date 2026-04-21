import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ThoughtTree.updatedAt, order: .reverse) private var trees: [ThoughtTree]
    @State private var showingNewTreeSheet = false
    @State private var newTreeTitle = ""
    @State private var searchText = ""

    private var pinnedTrees: [ThoughtTree] { trees.filter { $0.isPinned } }
    private var recentTrees: [ThoughtTree] { trees.filter { !$0.isPinned } }

    private var filteredTrees: [ThoughtTree] {
        guard !searchText.isEmpty else { return trees }
        return trees.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    private var weeklyAddedCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return trees.filter { $0.createdAt >= cutoff }.count
    }

    private var totalNodeCount: Int {
        trees.reduce(0) { $0 + $1.nodes.count }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.moBg.ignoresSafeArea()

            if trees.isEmpty {
                emptyState
            } else {
                content
            }

            if !trees.isEmpty {
                FloatingActionButton {
                    showingNewTreeSheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
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
                            .foregroundStyle(Color.moInk)
                    }
                    .accessibilityLabel("検索")
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color.moInk)
                    }
                    .accessibilityLabel("設定")
                }
            }
        }
        .sheet(isPresented: $showingNewTreeSheet) {
            newTreeSheet
        }
    }

    // MARK: - Content

    private var content: some View {
        List {
            if !searchText.isEmpty {
                searchResults
            } else {
                statsStripSection
                if !pinnedTrees.isEmpty { pinnedSection }
                recentSection
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.moBg)
        .environment(\.defaultMinListRowHeight, 0)
    }

    private var statsStripSection: some View {
        Section {
            HStack(spacing: 10) {
                MoStatCard(label: "テーマ", value: "\(trees.count)")
                MoStatCard(label: "ノード", value: "\(totalNodeCount)")
                MoStatCard(label: "今週追加", value: "\(weeklyAddedCount)", tone: .accent)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 16, trailing: 20))
            .listRowBackground(Color.moBg)
            .listRowSeparator(.hidden)
        }
    }

    private var pinnedSection: some View {
        Section {
            ForEach(pinnedTrees) { tree in
                NavigationLink {
                    TreeEditorView(tree: tree)
                } label: {
                    MoThemeCard(tree: tree)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 10, trailing: 20))
                .listRowBackground(Color.moBg)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .leading) { pinSwipe(tree) }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) { deleteSwipe(tree) }
            }
        } header: {
            sectionHeader(kicker: "Pinned", title: "ピン留め")
        }
    }

    private var recentSection: some View {
        Section {
            ForEach(recentTrees) { tree in
                NavigationLink {
                    TreeEditorView(tree: tree)
                } label: {
                    MoThemeRow(tree: tree)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowBackground(Color.moBg)
                .listRowSeparatorTint(Color.moHair)
                .swipeActions(edge: .leading) { pinSwipe(tree) }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) { deleteSwipe(tree) }
            }
        } header: {
            sectionHeader(kicker: "Recent", title: pinnedTrees.isEmpty ? "テーマ" : "最近")
        }
    }

    private var searchResults: some View {
        Section {
            if filteredTrees.isEmpty {
                Text("一致するテーマはありません")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.moInkMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.moBg)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(filteredTrees) { tree in
                    NavigationLink {
                        TreeEditorView(tree: tree)
                    } label: {
                        MoThemeRow(tree: tree)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.moBg)
                    .listRowSeparatorTint(Color.moHair)
                }
            }
        } header: {
            sectionHeader(kicker: "\(filteredTrees.count) Results", title: "検索結果")
        }
    }

    private func sectionHeader(kicker: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            MoKicker(text: kicker)
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .kerning(-0.3)
                .foregroundStyle(Color.moInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .listRowInsets(EdgeInsets())
        .textCase(nil)
    }

    @ViewBuilder
    private func pinSwipe(_ tree: ThoughtTree) -> some View {
        Button {
            tree.isPinned.toggle()
            tree.updatedAt = Date()
        } label: {
            Image(systemName: tree.isPinned ? "pin.slash" : "pin")
        }
        .tint(Color.moPin)
    }

    @ViewBuilder
    private func deleteSwipe(_ tree: ThoughtTree) -> some View {
        Button(role: .destructive) {
            modelContext.delete(tree)
        } label: {
            Image(systemName: "trash")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .strokeBorder(
                        Color.moHairStrong,
                        style: StrokeStyle(lineWidth: 1, dash: [3, 5])
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(Color.moInkFaint)
            }

            VStack(spacing: 6) {
                Text("まだテーマがありません")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.moInk)
                Text("頭の中のモヤモヤを、\n最初の一本のツリーから整理してみましょう。")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.moInkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260)
            }

            Button {
                showingNewTreeSheet = true
            } label: {
                Text("新しいテーマを作成")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.moBg)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.moInk)
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
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
