import SwiftUI
import SwiftData

struct TreeEditorView: View {
    @Environment(\.modelContext) private var modelContext
    let tree: ThoughtTree
    @State private var viewModel: TreeEditorViewModel?
    @State private var editingNode: ThoughtNode?
    @State private var showingTagSheet = false

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
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showingTagSheet = true
                } label: {
                    Image(systemName: "tag")
                }
                Menu {
                    Button {
                        viewModel?.startAddingChild(to: nil)
                    } label: {
                        Label("ルートノードを追加", systemImage: "plus.circle")
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
