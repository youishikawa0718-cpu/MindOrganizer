import SwiftUI

struct NodeEditSheet: View {
    let node: ThoughtNode
    let onSave: (String, String?) -> Void
    var onAddChild: (() -> Void)?
    var onDelete: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @AppStorage("accentKey") private var accentKey: String = "indigo"
    @State private var text: String
    @State private var note: String

    private let textLimit = 1000
    private let noteLimit = 5000

    init(
        node: ThoughtNode,
        onSave: @escaping (String, String?) -> Void,
        onAddChild: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.node = node
        self.onSave = onSave
        self.onAddChild = onAddChild
        self.onDelete = onDelete
        self._text = State(initialValue: node.text)
        self._note = State(initialValue: node.note ?? "")
    }

    private var breadcrumb: [String] {
        var result: [String] = []
        var current: ThoughtNode? = node.parent
        while let c = current {
            result.insert(c.text, at: 0)
            current = c.parent
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if !breadcrumb.isEmpty {
                            breadcrumbView
                        }

                        textField
                        noteField
                        metaChips

                        if onAddChild != nil || onDelete != nil {
                            actionButtons
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("ノードを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moBg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundStyle(Color.moInkMuted)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        onSave(text, trimmedNote.isEmpty ? nil : trimmedNote)
                        dismiss()
                    }
                    .foregroundStyle(Color.moAccent(accentKey))
                    .fontWeight(.semibold)
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var breadcrumbView: some View {
        HStack(spacing: 6) {
            ForEach(Array(breadcrumb.enumerated()), id: \.offset) { pair in
                Text(pair.element)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.moInkMuted)
                    .lineLimit(1)
                if pair.offset < breadcrumb.count - 1 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color.moInkFaint)
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var textField: some View {
        VStack(alignment: .leading, spacing: 6) {
            MoKicker(text: "Text")
            TextField("", text: $text, axis: .vertical)
                .font(.system(size: 17))
                .foregroundStyle(Color.moInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.moBgElev)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.moHairStrong, lineWidth: 1)
                )
                .onChange(of: text) { _, newValue in
                    if newValue.count > textLimit {
                        text = String(newValue.prefix(textLimit))
                    }
                }

            HStack {
                Spacer()
                Text("\(text.count) / \(textLimit)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.moInkFaint)
            }
        }
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: 6) {
            MoKicker(text: "Note")
            TextEditor(text: $note)
                .font(.system(size: 14))
                .foregroundStyle(Color.moInk)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 130)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.moBgElev)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.moHair, lineWidth: 1)
                )
                .onChange(of: note) { _, newValue in
                    if newValue.count > noteLimit {
                        note = String(newValue.prefix(noteLimit))
                    }
                }

            HStack {
                Spacer()
                Text("\(note.count) / \(noteLimit)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.moInkFaint)
            }
        }
    }

    private var metaChips: some View {
        HStack(spacing: 8) {
            metaChip("深さ \(node.depth)")
            metaChip("子 \(node.children.count)")
            metaChip("作成 \(node.createdAt.relativeDisplay)")
            Spacer(minLength: 0)
        }
    }

    private func metaChip(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.moInkMuted)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(Color.moBgElev2)
            )
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            if let onAddChild {
                Button {
                    onAddChild()
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("子を追加")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.moInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.moBgElev)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.moHairStrong, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            if let onDelete {
                Button {
                    onDelete()
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .semibold))
                        Text("削除")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.moDanger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.moDanger.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.moDanger.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
