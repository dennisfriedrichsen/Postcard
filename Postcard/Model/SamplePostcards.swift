import SwiftData
import SwiftUI
import UIKit

@MainActor
enum SamplePostcards {
    private static let seedKey = "didSeedSamplePostcards.v1"

    static func seedIfNeeded(in context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seedKey) else { return }

        let samples: [(String, String, Date, Double, Double)] = [
            ("copenhagen", "The evening stayed bright long after we stopped keeping track of time.", date(2026, 6, 18), 55.6761, 12.5683),
            ("kyoto", "Rain left the old streets shining just for us.", date(2026, 4, 8), 35.0116, 135.7681),
            ("lake", "We were the first ones in the water that morning.", date(2025, 8, 27), 45.9917, 9.2619)
        ]
        let places = ["Copenhagen, Denmark", "Kyoto, Japan", "Lake Como, Italy"]

        for (index, sample) in samples.enumerated() {
            guard let image = UIImage(named: sample.0),
                  let data = image.jpegData(compressionQuality: 0.84) else { continue }
            context.insert(PostcardEntry(
                photoData: data,
                sentence: sample.1,
                place: places[index],
                date: sample.2,
                latitude: sample.3,
                longitude: sample.4
            ))
        }
        try? context.save()
        UserDefaults.standard.set(true, forKey: seedKey)
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
}
