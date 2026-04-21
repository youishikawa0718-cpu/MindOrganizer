import SwiftUI

struct SegmentedMini<Value: Hashable>: View {
    @Binding var selection: Value
    let options: [Option]

    struct Option: Identifiable {
        let value: Value
        let label: String
        var id: Value { value }
    }

    init(selection: Binding<Value>, options: [Option]) {
        self._selection = selection
        self.options = options
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options) { option in
                segmentButton(for: option)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.moBgElev2)
        )
    }

    private func segmentButton(for option: Option) -> some View {
        let isSelected = option.value == selection
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selection = option.value
            }
        } label: {
            Text(option.label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? Color.moInk : Color.moInkMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(segmentBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func segmentBackground(isSelected: Bool) -> some View {
        if isSelected {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.moBgElev)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.moHair, lineWidth: 1)
            }
        } else {
            Color.clear
        }
    }
}

#Preview {
    @Previewable @State var selected: String = "medium"
    SegmentedMini(
        selection: $selected,
        options: [
            .init(value: "compact", label: "コンパクト"),
            .init(value: "medium", label: "標準"),
            .init(value: "comfortable", label: "ゆったり"),
        ]
    )
    .padding()
    .background(Color.moBg)
}
