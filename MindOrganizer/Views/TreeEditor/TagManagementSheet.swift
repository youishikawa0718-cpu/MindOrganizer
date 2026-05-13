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
                    TextField("タグ名", text: $newTagName)

                    colorPalette

                    Button {
                        createTag()
                    } label: {
                        Label("タグを追加", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
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

    private var colorPalette: some View {
        // List + Button(.plain) の組み合わせで Circle が描画されない iOS 17 不具合の回避策として
        // onTapGesture でハンドリングする。横幅不足は ScrollView で吸収。
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Color.tagColors, id: \.self) { hex in
                    let isSelected = hex == selectedColorHex
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.moInk : Color.moHair,
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )
                        .contentShape(Circle())
                        .onTapGesture { selectedColorHex = hex }
                        .accessibilityLabel("色 \(hex)")
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
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
