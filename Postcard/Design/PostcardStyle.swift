import SwiftUI

enum PostcardStyle {
    static let horizontalMargin: CGFloat = 20
    static let photoRadius: CGFloat = 3
    static let sentence = Font.system(.title2, design: .serif, weight: .regular)
    static let detailSentence = Font.system(.title, design: .serif, weight: .regular)
}

extension Color {
    static let postcardBackground = Color(uiColor: .systemBackground)
    static let postcardSecondary = Color(uiColor: .secondaryLabel)
}
