import SwiftUI

struct NodeEditSheet: View {
    let node: ThoughtNode
    let onSave: (String, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var note: String

    init(node: ThoughtNode, onSave: @escaping (String, String?) -> Void) {
        self.node = node
        self.onSave = onSave
        self._text = State(initialValue: node.text)
        self._note = State(initialValue: node.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("テキスト") {
                    TextField("ノードのテキスト", text: $text)
                }
                Section("メモ") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
                Section {
                    LabeledContent("作成日", value: node.createdAt.shortDisplay)
                    LabeledContent("更新日", value: node.updatedAt.shortDisplay)
                    if !node.children.isEmpty {
                        LabeledContent("子ノード", value: "\(node.children.count)個")
                    }
                }
            }
            .navigationTitle("ノードを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        onSave(text, trimmedNote.isEmpty ? nil : trimmedNote)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
