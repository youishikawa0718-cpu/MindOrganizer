import SwiftUI
import SwiftData

struct TagManagementSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]
    let tree: ThoughtTree

    @State private var newTagName = ""
    @State private var selectedColorHex = Color.tagColors[0]

    var body: some View {
        NavigationStack {
            List {
                Section("新しいタグ") {
                    HStack {
                        TextField("タグ名", text: $newTagName)
                        colorPicker
                        Button {
                            createTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("タグを選択") {
                    ForEach(allTags) { tag in
                        HStack {
                            TagChip(tag: tag)
                            Spacer()
                            if tree.tags.contains(where: { $0.id == tag.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleTag(tag)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(allTags[index])
                        }
                    }
                }
            }
            .navigationTitle("タグ管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var colorPicker: some View {
        Menu {
            ForEach(Color.tagColors, id: \.self) { hex in
                Button {
                    selectedColorHex = hex
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 16, height: 16)
                        if hex == selectedColorHex {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Circle()
                .fill(Color(hex: selectedColorHex))
                .frame(width: 24, height: 24)
        }
    }

    private func createTag() {
        let trimmed = newTagName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let tag = Tag(name: trimmed, colorHex: selectedColorHex)
        modelContext.insert(tag)
        tree.tags.append(tag)
        tree.updatedAt = Date()
        newTagName = ""
    }

    private func toggleTag(_ tag: Tag) {
        if let index = tree.tags.firstIndex(where: { $0.id == tag.id }) {
            tree.tags.remove(at: index)
        } else {
            tree.tags.append(tag)
        }
        tree.updatedAt = Date()
    }
}
