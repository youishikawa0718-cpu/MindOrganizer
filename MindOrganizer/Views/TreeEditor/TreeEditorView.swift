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

    var body: some View {
        Group {
            if let vm = viewModel {
                treeContent(vm)
            } else {
                ProgressView()
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
                        Image(systemName: "list.bullet")
                    }
                } else {
                    EditButton()
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showingTagSheet = true
                } label: {
                    Image(systemName: "tag")
                }
                if !showsMindMap {
                    Button {
                        withAnimation { showsMindMap = true }
                    } label: {
                        Image(systemName: "circle.grid.cross")
                    }
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
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TreeEditorViewModel(tree: tree, modelContext: modelContext)
            }
        }
        .sheet(item: $editingNode) { node in
            NodeEditSheet(node: node) { text, note in
                viewModel?.updateNode(node, text: text, note: note)
            }
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
                        .listRowInsets(EdgeInsets(
                            top: 4,
                            leading: CGFloat(node.depth) * 24 + 16,
                            bottom: 4,
                            trailing: 16
                        ))
                    }
                    .onMove { source, destination in
                        withAnimation {
                            vm.moveNodes(from: source, to: destination)
                        }
                    }
                }
                .listStyle(.plain)

                if vm.isAddingNode {
                    addNodeBar(vm)
                }

                bottomToolbar(vm)
            }
        }
    }

    // MARK: - Add Node Bar

    private func addNodeBar(_ vm: TreeEditorViewModel) -> some View {
        HStack {
            if let parent = vm.addingParent {
                Text("↳ \(parent.text)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            TextField("ノードを入力", text: Bindable(vm).newNodeText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    vm.confirmAddNode()
                }
            Button {
                vm.confirmAddNode()
            } label: {
                Image(systemName: "checkmark.circle.fill")
            }
            .disabled(vm.newNodeText.trimmingCharacters(in: .whitespaces).isEmpty)
            Button {
                vm.cancelAddNode()
            } label: {
                Image(systemName: "xmark.circle")
            }
        }
        .padding()
        .background(.bar)
    }

    // MARK: - Bottom Toolbar

    private func bottomToolbar(_ vm: TreeEditorViewModel) -> some View {
        HStack {
            Button {
                vm.startAddingChild(to: nil)
            } label: {
                Label("ノードを追加", systemImage: "plus.circle")
            }
            Spacer()
            Text("\(vm.flatNodes.count)個のノード")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
