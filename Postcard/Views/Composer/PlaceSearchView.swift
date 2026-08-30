import MapKit
import SwiftUI

struct PlaceSearchResult: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

struct PlaceSearchView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (PlaceSearchResult) -> Void
    @State private var query = ""
    @State private var results: [PlaceSearchResult] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            Group {
                if query.isEmpty {
                    ContentUnavailableView(
                        "Find a place",
                        systemImage: "location.magnifyingglass",
                        description: Text("Search for a city, landmark, or neighborhood.")
                    )
                } else if results.isEmpty && !isSearching {
                    ContentUnavailableView.search(text: query)
                } else {
                    List(results) { result in
                        Button {
                            onSelect(result)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(result.name).foregroundStyle(.primary)
                                if !result.subtitle.isEmpty {
                                    Text(result.subtitle).font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Choose a Place")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "City or landmark")
            .overlay { if isSearching { ProgressView() } }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .task(id: query) {
                guard !query.trimmed.isEmpty else {
                    results = []
                    return
                }
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await search()
            }
        }
    }

    private func search() async {
        isSearching = true
        defer { isSearching = false }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]
        guard let response = try? await MKLocalSearch(request: request).start() else {
            results = []
            return
        }
        results = response.mapItems.prefix(12).map { item in
            let placemark = item.placemark
            let primary = item.name ?? placemark.locality ?? query
            let parts = [placemark.locality, placemark.administrativeArea, placemark.country]
                .compactMap { $0 }
                .filter { $0 != primary }
            return PlaceSearchResult(
                name: ([primary] + parts.suffix(1)).joined(separator: ", "),
                subtitle: parts.dropLast().joined(separator: ", "),
                coordinate: placemark.coordinate
            )
        }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
