import CoreLocation
import SwiftUI
import UIKit
import XCTest
@testable import Postcard

final class PostcardTests: XCTestCase {
    func testEntryPreservesTheFourEssentialFields() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let entry = PostcardEntry(
            photoData: Data([1, 2, 3]),
            sentence: "A small moment worth keeping.",
            place: "Chicago, United States",
            date: date,
            latitude: 41.8781,
            longitude: -87.6298
        )

        XCTAssertEqual(entry.photoData, Data([1, 2, 3]))
        XCTAssertEqual(entry.sentence, "A small moment worth keeping.")
        XCTAssertEqual(entry.place, "Chicago, United States")
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.coordinate?.latitude, 41.8781)
        XCTAssertEqual(entry.coordinate?.longitude, -87.6298)
    }

    func testInvalidPhotoFallsBackSafely() {
        let before = Date.now
        let imported = PhotoMetadataService.inspect(Data([0x00, 0x01]))

        XCTAssertNil(imported.coordinate)
        XCTAssertGreaterThanOrEqual(imported.date, before)
        XCTAssertEqual(imported.data, Data([0x00, 0x01]))
    }

    @MainActor
    func testPhotoViewportStaysFourByFiveForAnExtremelyTallImage() throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 400))
        let image = renderer.image { context in
            UIColor.systemGreen.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 100, height: 400))
        }
        let data = try XCTUnwrap(image.pngData())
        let host = UIHostingController(rootView: PostcardPhoto(data: data))

        let size = host.sizeThatFits(in: CGSize(width: 320, height: 2_000))

        XCTAssertEqual(size.width, 320, accuracy: 0.5)
        XCTAssertEqual(size.height, 400, accuracy: 0.5)
    }
}
