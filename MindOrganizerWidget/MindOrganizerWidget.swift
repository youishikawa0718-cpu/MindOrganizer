import WidgetKit
import SwiftUI
import SwiftData

struct LatestTreeEntry: TimelineEntry {
    let date: Date
    let treeTitle: String
    let nodeCount: Int
    let isEmpty: Bool
}

struct MindOrganizerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LatestTreeEntry {
        LatestTreeEntry(date: .now, treeTitle: "思考テーマ", nodeCount: 5, isEmpty: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (LatestTreeEntry) -> Void) {
        let entry = fetchLatestEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LatestTreeEntry>) -> Void) {
        let entry = fetchLatestEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchLatestEntry() -> LatestTreeEntry {
        let container = SharedModelContainer.container
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ThoughtTree>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            let trees = try context.fetch(descriptor)
            if let latest = trees.first {
                return LatestTreeEntry(
                    date: .now,
                    treeTitle: latest.title,
                    nodeCount: latest.nodes.count,
                    isEmpty: false
                )
            }
        } catch {
            // fetch failure — show empty state
        }
        return LatestTreeEntry(date: .now, treeTitle: "", nodeCount: 0, isEmpty: true)
    }
}

struct MindOrganizerWidgetEntryView: View {
    var entry: LatestTreeEntry

    var body: some View {
        if entry.isEmpty {
            VStack(spacing: 4) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("テーマなし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(Color.accentColor)
                    Spacer()
                    Text("\(entry.nodeCount)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(entry.treeTitle)
                    .font(.headline)
                    .lineLimit(2)
                Text("最新のテーマ")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(2)
        }
    }
}

@main
struct MindOrganizerWidget: Widget {
    let kind = "MindOrganizerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MindOrganizerTimelineProvider()) { entry in
            MindOrganizerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("MindOrganizer")
        .description("最新の思考テーマを表示します")
        .supportedFamilies([.systemSmall])
    }
}
