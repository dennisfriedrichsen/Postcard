import CoreLocation
import Foundation
import SwiftData

@Model
final class PostcardEntry {
    var id: UUID
    @Attribute(.externalStorage) var photoData: Data
    var sentence: String
    var place: String
    var date: Date
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        photoData: Data,
        sentence: String,
        place: String,
        date: Date,
        latitude: Double? = nil,
        longitude: Double? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.photoData = photoData
        self.sentence = sentence
        self.place = place
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
