import SwiftUI

struct RootView: View {
    @State private var showingComposer = false

    var body: some View {
        TabView {
            Tab("Postcards", systemImage: "rectangle.stack") {
                CollectionView(showingComposer: $showingComposer)
            }
            Tab("Places", systemImage: "map") {
                PlacesMapView(showingComposer: $showingComposer)
            }
        }
        .tint(.primary)
        .sheet(isPresented: $showingComposer) {
            PostcardComposer()
        }
    }
}
