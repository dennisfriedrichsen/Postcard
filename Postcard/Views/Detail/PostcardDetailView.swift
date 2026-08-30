import MapKit
import SwiftData
import SwiftUI

struct PostcardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let entry: PostcardEntry
    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false
    @State private var showingInfo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PostcardPhoto(data: entry.photoData)
                    .accessibilityLabel("Photo from \(entry.place)")

                VStack(alignment: .leading, spacing: 22) {
                    Text(entry.sentence)
                        .font(PostcardStyle.detailSentence)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(entry.place)
                            .font(.headline)
                        Text(entry.date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let coordinate = entry.coordinate {
                        Button {
                            withAnimation(reduceMotion ? nil : .snappy) { showingInfo.toggle() }
                        } label: {
                            HStack {
                                Label("Location", systemImage: "location")
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption.weight(.semibold))
                                    .rotationEffect(.degrees(showingInfo ? 180 : 0))
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        }
                        if showingInfo {
                            Map(initialPosition: .region(MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                            ))) {
                                Marker(entry.place, coordinate: coordinate)
                            }
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .allowsHitTesting(false)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding(.horizontal, PostcardStyle.horizontalMargin)
                .padding(.vertical, 28)
            }
        }
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit", systemImage: "pencil") { showingEditor = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { showingDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.25))
                }
                .accessibilityLabel("Postcard actions")
            }
        }
        .sheet(isPresented: $showingEditor) { PostcardComposer(entry: entry) }
        .confirmationDialog("Delete this postcard?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Postcard", role: .destructive) {
                modelContext.delete(entry)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}
