import CoreLocation

enum PlaceResolver {
    static func name(for coordinate: CLLocationCoordinate2D) async -> String? {
        let geocoder = CLGeocoder()
        guard let mark = try? await geocoder.reverseGeocodeLocation(
            CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ).first else { return nil }
        return [mark.locality ?? mark.name, mark.country]
            .compactMap { $0 }
            .uniqued()
            .joined(separator: ", ")
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
