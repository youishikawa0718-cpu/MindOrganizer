import SwiftUI
import SwiftData

struct TreeEditorView: View {
    @Environment(\.modelContext) private var modelContext
    let tree: ThoughtTree
    @State private var viewModel: TreeEditorViewModel?
    @State private var editingNode: ThoughtNode?
    @State private var showingTagSheet = false
    @State private var showsMindMap = false
    @State private var showingSnapshots = false
    @State private var exportText: String?

    @AppStorage("accentKey") private var accentKey: String = "indigo"

    private var maxDepth: Int {
        (tree.nodes.map(\.depth).max() ?? -1) + 1
    }

    private var allCollapsed: Bool {
        let branches = tree.nodes.filter { !$0.children.isEmpty }
        return !branches.isEmpty && branches.allSatisfy { $0.isCollapsed }
    }

    var body: some View {
        ZStack {
            Color.moBg.ignoresSafeArea()

            Group {
                if let vm = viewModel {
                    treeContent(vm)
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle(tree.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if showsMindMap {
                    Button {
                        withAnimation { showsMindMap = false }
                    } label: {
                        Image(systemName: "list.bullet.indent")
                            .foregroundStyle(Color.moAccent(accentKey))
                    }
                    .accessibilityLabel("リスト表示に切り替え")
                } else {
                    EditButton()
                        .tint(Color.moAccent(accentKey))
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showingTagSheet = true
                } label: {
                    Image(systemName: "tag")
                        .foregroundStyle(Color.moInk)
                }
                .accessibilityLabel("タグを管理")
                if !showsMindMap {
                    Button {
                        withAnimation { showsMindMap = true }
                    } label: {
                        Image(systemName: "circle.hexagongrid.fill")
                            .foregroundStyle(Color.moInk)
                    }
                    .accessibilityLabel("マインドマップに切り替え")
                }
                Menu {
                    Button {
                        viewModel?.startAddingChild(to: nil)
                    } label: {
                        Label("ルートノードを追加", systemImage: "plus.circle")
                    }
                    Button {
                        showingSnapshots = true
                    } label: {
                        Label("スナップショット", systemImage: "camera")
                    }
                    Button {
                        exportText = ExportService.exportAsMarkdown(tree: tree)
                    } label: {
                        Label("マークダウンで共有", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.moInk)
                }
                .accessibilityLabel("その他のオプション")
            }
        }
        .toolbarBackground(Color.moBg, for: .navigationBar)
        .onAppear {
            if viewModel == nil {
                viewModel = TreeEditorViewModel(tree: tree, modelContext: modelContext)
            }
        }
        .sheet(item: $editingNode) { node in
            NodeEditSheet(
                node: node,
                onSave: { text, note in
                    viewModel?.updateNode(node, text: text, note: note)
                },
                onAddChild: { viewModel?.startAddingChild(to: node) },
                onDelete: { viewModel?.deleteNode(node) }
            )
        }
        .sheet(isPresented: $showingTagSheet) {
            TagManagementSheet(tree: tree)
        }
        .sheet(isPresented: $showingSnapshots) {
            SnapshotListView(tree: tree)
        }
        .sheet(isPresented: Binding(
            get: { exportText != nil },
            set: { if !$0 { exportText = nil } }
        )) {
            if let text = exportText {
                ShareSheet(items: [text])
            }
        }
        .alert("制限", isPresented: Binding(
            get: { viewModel?.alertMessage != nil },
            set: { if !$0 { viewModel?.alertMessage = nil } }
        )) {
            Button("OK") { viewModel?.alertMessage = nil }
        } message: {
            Text(viewModel?.alertMessage ?? "")
        }
    }

    // MARK: - Tree Content

    @ViewBuilder
    private func treeContent(_ vm: TreeEditorViewModel) -> some View {
        if vm.flatNodes.isEmpty && !vm.isAddingNode {
            EmptyNodeStateView {
                vm.startAddingChild(to: nil)
            }
        } else if showsMindMap {
            MindMapView(
                tree: tree,
                onEditNode: { editingNode = $0 },
                onToggleCollapse: { node in
                    vm.toggleCollapse(node)
                }
            )
        } else {
            VStack(spacing: 0) {
                statsHeader(vm)
                nodeList(vm)
                if vm.isAddingNode {
                    addNodeBar(vm)
                }
                bottomToolbar(vm)
            }
        }
    }

    private func statsHeader(_ vm: TreeEditorViewModel) -> some View {
        HStack(alignment: .center) {
            MoKicker(text: "\(vm.flatNodes.count) NODES · \(maxDepth) LEVELS")
            Spacer()
            if tree.nodes.contains(where: { !$0.children.isEmpty }) {
                Button {
                    toggleAllCollapse(vm)
                } label: {
                    Text(allCollapsed ? "すべて展開" : "すべて折りたたむ")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.moAccent(accentKey))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func toggleAllCollapse(_ vm: TreeEditorViewModel) {
        let target = !allCollapsed
        for node in tree.nodes where !node.children.isEmpty {
            node.isCollapsed = target
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            vm.rebuildFlatNodes()
        }
    }

    private func nodeList(_ vm: TreeEditorViewModel) -> some View {
        List {
            ForEach(vm.flatNodes) { node in
                NodeRowView(
                    node: node,
                    onToggleCollapse: { vm.toggleCollapse(node) },
                    onAddChild: { vm.startAddingChild(to: node) },
                    onEdit: { editingNode = node },
                    onDelete: { vm.deleteNode(node) },
                    onIndent: { vm.indentNode(node) },
                    onOutdent: { vm.outdentNode(node) }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.moBg)
                .listRowSeparator(.hidden)
            }
            .onMove { source, destination in
                withAnimation {
                    vm.moveNodes(from: source, to: destination)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.moBg)
        .environment(\.defaultMinListRowHeight, 0)
    }

    // MARK: - Add Node Bar

    private func addNodeBar(_ vm: TreeEditorViewModel) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.moHair)
                .frame(height: 1)
            HStack(spacing: 10) {
                if let parent = vm.addingParent {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.turn.down.right")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.moInkFaint)
                        Text(parent.text)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.moInkMuted)
                            .lineLimit(1)
                    }
                }
                TextField("ノードを入力", text: Bindable(vm).newNodeText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.moBgElev2)
                    )
                    .onSubmit {
                        vm.confirmAddNode()
                    }
                Button {
                    vm.confirmAddNode()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(vm.newNodeText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.moInkFaint : Color.moAccent(accentKey))
                }
                .disabled(vm.newNodeText.trimmingCharacters(in: .whitespaces).isEmpty)
                Button {
                    vm.cancelAddNode()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.moInkMuted)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.moBgElev)
        }
    }

    // MARK: - Bottom Toolbar

    private func bottomToolbar(_ vm: TreeEditorViewModel) -> some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color.moBg.opacity(0), Color.moBg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 16)
            .offset(y: -16)
            .allowsHitTesting(false)

            HStack(spacing: 10) {
                Button {
                    vm.startAddingChild(to: nil)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("ノードを追加")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color.moBg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.moInk)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    showingSnapshots = true
                } label: {
                    Image(systemName: "camera")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.moInk)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.moBgElev)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.moHair, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("スナップショット")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.moBg)
        }
    }
}
