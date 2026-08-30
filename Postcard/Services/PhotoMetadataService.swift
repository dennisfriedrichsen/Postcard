import CoreLocation
import Foundation
import ImageIO

struct ImportedPhoto: Sendable {
    let data: Data
    let date: Date
    let coordinate: CLLocationCoordinate2D?
}

enum PhotoMetadataService {
    static func inspect(_ data: Data) -> ImportedPhoto {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return ImportedPhoto(data: data, date: .now, coordinate: nil)
        }

        let date = captureDate(in: properties) ?? .now
        let coordinate = coordinate(in: properties)
        return ImportedPhoto(data: data, date: date, coordinate: coordinate)
    }

    private static func captureDate(in properties: [CFString: Any]) -> Date? {
        let exif = properties[kCGImagePropertyExifDictionary] as? [CFString: Any]
        let raw = exif?[kCGImagePropertyExifDateTimeOriginal] as? String
            ?? properties[kCGImagePropertyTIFFDictionary].flatMap { ($0 as? [CFString: Any])?[kCGImagePropertyTIFFDateTime] as? String }
        guard let raw else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter.date(from: raw)
    }

    private static func coordinate(in properties: [CFString: Any]) -> CLLocationCoordinate2D? {
        guard let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any],
              let rawLatitude = gps[kCGImagePropertyGPSLatitude] as? Double,
              let rawLongitude = gps[kCGImagePropertyGPSLongitude] as? Double else { return nil }
        let latitude = (gps[kCGImagePropertyGPSLatitudeRef] as? String) == "S" ? -rawLatitude : rawLatitude
        let longitude = (gps[kCGImagePropertyGPSLongitudeRef] as? String) == "W" ? -rawLongitude : rawLongitude
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
