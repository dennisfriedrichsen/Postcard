import SwiftData
import SwiftUI

struct CollectionView: View {
    @Binding var showingComposer: Bool
    @Query(sort: \PostcardEntry.date, order: .reverse) private var entries: [PostcardEntry]

    private var groups: [(month: Date, entries: [PostcardEntry])] {
        let calendar = Calendar.autoupdatingCurrent
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.date(from: calendar.dateComponents([.year, .month], from: entry.date)) ?? entry.date
        }
        return grouped.keys.sorted(by: >).map { ($0, grouped[$0] ?? []) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    EmptyCollectionView(action: { showingComposer = true })
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 34, pinnedViews: [.sectionHeaders]) {
                            ForEach(groups, id: \.month) { group in
                                Section {
                                    ForEach(group.entries) { entry in
                                        NavigationLink(value: entry) {
                                            PostcardRow(entry: entry)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } header: {
                                    Text(group.month, format: .dateTime.month(.wide).year())
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                        .tracking(0.6)
                                        .padding(.horizontal, PostcardStyle.horizontalMargin)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.background.opacity(0.94))
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(Color.postcardBackground)
            .navigationTitle("Postcards")
            .navigationDestination(for: PostcardEntry.self) { entry in
                PostcardDetailView(entry: entry)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Postcard", systemImage: "plus") { showingComposer = true }
                        .accessibilityHint("Create a postcard from a photo")
                }
            }
        }
    }
}

private struct PostcardRow: View {
    let entry: PostcardEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            PostcardPhoto(data: entry.photoData)
                .clipShape(RoundedRectangle(cornerRadius: PostcardStyle.photoRadius, style: .continuous))
            Text(entry.sentence)
                .font(PostcardStyle.sentence)
                .foregroundStyle(.primary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 5) {
                Text(entry.place)
                Text("·")
                Text(entry.date, format: .dateTime.day().month(.abbreviated))
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, PostcardStyle.horizontalMargin)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.place), \(entry.date.formatted(date: .long, time: .omitted)). \(entry.sentence)")
    }
}

private struct EmptyCollectionView: View {
    let action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Your first postcard", systemImage: "photo")
        } description: {
            Text("One place. One photo. One sentence.")
        } actions: {
            Button("Choose a Photo", action: action)
                .buttonStyle(.borderedProminent)
                .tint(.primary)
        }
    }
}
