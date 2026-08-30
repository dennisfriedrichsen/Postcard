import CoreLocation
import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct PostcardComposer: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    private let entry: PostcardEntry?

    @State private var photoData: Data?
    @State private var sentence: String
    @State private var place: String
    @State private var date: Date
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var showingPlaceSearch = false
    @State private var isReadingPhoto = false
    @FocusState private var sentenceFocused: Bool

    init(entry: PostcardEntry? = nil) {
        self.entry = entry
        _photoData = State(initialValue: entry?.photoData)
        _sentence = State(initialValue: entry?.sentence ?? "")
        _place = State(initialValue: entry?.place ?? "")
        _date = State(initialValue: entry?.date ?? .now)
        _coordinate = State(initialValue: entry?.coordinate)
    }

    private var canSave: Bool {
        photoData != nil && !sentence.trimmed.isEmpty && !place.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    photoSection
                    if photoData != nil { detailsSection }
                }
                .padding(.horizontal, PostcardStyle.horizontalMargin)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(entry == nil ? "New Postcard" : "Edit Postcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
        .interactiveDismissDisabled(sentenceFocused && !sentence.isEmpty)
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task { await importPhoto(from: item) }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPicker { image in
                if let data = image.jpegData(compressionQuality: 0.9) {
                    apply(ImportedPhoto(data: data, date: .now, coordinate: nil))
                }
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPlaceSearch) {
            PlaceSearchView { result in
                place = result.name
                coordinate = result.coordinate
            }
        }
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let photoData {
                PostcardPhoto(data: photoData)
                    .clipShape(RoundedRectangle(cornerRadius: PostcardStyle.photoRadius, style: .continuous))
                    .overlay(alignment: .bottomTrailing) { changePhotoMenu }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 34, weight: .light))
                        VStack(spacing: 5) {
                            Text("Choose a photo").font(.headline)
                            Text("The date and place will be filled in when possible.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 330)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take a Photo", systemImage: "camera") { showingCamera = true }
                        .font(.subheadline.weight(.medium))
                }
            }
            if isReadingPhoto { ProgressView("Reading photo details…").font(.footnote) }
        }
    }

    private var changePhotoMenu: some View {
        Menu {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Choose Another", systemImage: "photo")
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo", systemImage: "camera") { showingCamera = true }
            }
        } label: {
            Label("Change", systemImage: "photo")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(.black.opacity(0.5), in: Capsule())
                .padding(12)
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 9) {
                TextField("What will you remember?", text: $sentence, axis: .vertical)
                    .font(PostcardStyle.sentence)
                    .lineLimit(2...4)
                    .focused($sentenceFocused)
                    .onChange(of: sentence) { _, value in
                        if value.count > 180 { sentence = String(value.prefix(180)) }
                    }
                    .accessibilityHint("Write one short sentence")
                HStack {
                    Text("ONE SENTENCE")
                    Spacer()
                    Text("\(sentence.count)/180")
                }
                .font(.caption2.weight(.semibold))
                .tracking(0.7)
                .foregroundStyle(.secondary)
            }

            Divider()

            Button { showingPlaceSearch = true } label: {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PLACE").font(.caption2.weight(.semibold)).tracking(0.7)
                        Text(place.isEmpty ? "Choose a place" : place)
                            .font(.body)
                            .foregroundStyle(place.isEmpty ? .secondary : .primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)

            DatePicker("Date", selection: $date, in: ...Date.now, displayedComponents: .date)
        }
    }

    private func importPhoto(from item: PhotosPickerItem) async {
        isReadingPhoto = true
        defer { isReadingPhoto = false }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        apply(PhotoMetadataService.inspect(data))
    }

    private func apply(_ photo: ImportedPhoto) {
        photoData = photo.data
        date = photo.date
        coordinate = photo.coordinate
        if let coordinate = photo.coordinate {
            Task {
                if let inferredPlace = await PlaceResolver.name(for: coordinate) { place = inferredPlace }
            }
        }
        if sentence.isEmpty {
            Task { @MainActor in
                await Task.yield()
                sentenceFocused = true
            }
        }
    }

    private func save() {
        guard let photoData else { return }
        if let entry {
            entry.photoData = photoData
            entry.sentence = sentence.trimmed
            entry.place = place.trimmed
            entry.date = date
            entry.latitude = coordinate?.latitude
            entry.longitude = coordinate?.longitude
        } else {
            modelContext.insert(PostcardEntry(
                photoData: photoData,
                sentence: sentence.trimmed,
                place: place.trimmed,
                date: date,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude
            ))
        }
        try? modelContext.save()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
