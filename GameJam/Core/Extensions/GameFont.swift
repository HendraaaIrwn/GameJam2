import SwiftUI

enum GameFont {
    static let regular = "LondrinaSolid-Regular"
    static let heavy = "LondrinaSolid-Black"
    static let bold = "LondrinaSolid-Black"
    static let light = "LondrinaSolid-Light"
    static let thin = "LondrinaSolid-Thin"
    static let pixelifySans = "PixelifySans-Regular"

    static func swiftUI(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold, .heavy, .black, .semibold:
            return .custom(heavy, size: size)
        case .light:
            return .custom(light, size: size)
        case .thin, .ultraLight:
            return .custom(thin, size: size)
        default:
            return .custom(regular, size: size)
        }
    }
}
