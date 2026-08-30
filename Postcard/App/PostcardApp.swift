import SwiftData
import SwiftUI

@main
struct PostcardApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: PostcardEntry.self)
        } catch {
            fatalError("Unable to create the local postcard store: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .task { SamplePostcards.seedIfNeeded(in: container.mainContext) }
        }
        .modelContainer(container)
    }
}
