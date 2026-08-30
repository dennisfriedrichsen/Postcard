import MapKit
import SwiftData
import SwiftUI

struct PlacesMapView: View {
    @Binding var showingComposer: Bool
    @Query(sort: \PostcardEntry.date, order: .reverse) private var entries: [PostcardEntry]
    @State private var position: MapCameraPosition = .automatic
    @State private var selection: UUID?

    private var locatedEntries: [PostcardEntry] { entries.filter { $0.coordinate != nil } }
    private var selectedEntry: PostcardEntry? { entries.first { $0.id == selection } }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if locatedEntries.isEmpty {
                    ContentUnavailableView(
                        "No places yet",
                        systemImage: "map",
                        description: Text("Locations found in your photos will appear here.")
                    )
                } else {
                    Map(position: $position, selection: $selection) {
                        ForEach(locatedEntries) { entry in
                            if let coordinate = entry.coordinate {
                                Annotation(entry.place, coordinate: coordinate) {
                                    MapPinThumbnail(entry: entry, selected: selection == entry.id)
                                }
                                .tag(entry.id)
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                    .mapControls {
                        MapCompass()
                        MapScaleView()
                    }
                    .ignoresSafeArea(edges: .bottom)
                }

                if let selectedEntry {
                    NavigationLink(value: selectedEntry) {
                        MapPostcardPreview(entry: selectedEntry)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.snappy, value: selection)
            .navigationTitle("Places")
            .navigationDestination(for: PostcardEntry.self) { PostcardDetailView(entry: $0) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Postcard", systemImage: "plus") { showingComposer = true }
                }
            }
        }
    }
}

private struct MapPinThumbnail: View {
    let entry: PostcardEntry
    let selected: Bool

    var body: some View {
        PostcardImage(data: entry.photoData)
            .frame(width: selected ? 52 : 42, height: selected ? 52 : 42)
            .clipShape(Circle())
            .overlay { Circle().stroke(.white, lineWidth: 3) }
            .shadow(color: .black.opacity(0.22), radius: 4, y: 2)
            .animation(.snappy, value: selected)
            .accessibilityLabel(entry.place)
    }
}

private struct MapPostcardPreview: View {
    let entry: PostcardEntry

    var body: some View {
        HStack(spacing: 14) {
            PostcardImage(data: entry.photoData)
                .frame(width: 74, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                Text(entry.place)
                    .font(.headline)
                    .lineLimit(1)
                Text(entry.sentence)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens postcard")
    }
}
