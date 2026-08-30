import SwiftUI
import UIKit

struct PostcardImage: View {
    let data: Data

    var body: some View {
        Group {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .overlay { Image(systemName: "photo").foregroundStyle(.secondary) }
            }
        }
        .clipped()
    }
}

/// A predictable photographic viewport for scroll views. The clear shape owns
/// the 4:5 layout; the source image is only responsible for filling it.
struct PostcardPhoto: View {
    let data: Data

    var body: some View {
        Color.clear
            .aspectRatio(4 / 5, contentMode: .fit)
            .overlay {
                PostcardImage(data: data)
            }
            .clipped()
    }
}
