import SwiftUI

extension Font {

    /// Hiragino Mincho ProN — traditional Japanese serif. Use for prominent
    /// headword display and example sentences where an elegant, "dictionary"
    /// feel is wanted.
    static func japaneseSerif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(minchoPostScriptName(for: weight), size: size)
    }

    /// Hiragino Sans — clean modern Japanese sans-serif. Use for readings,
    /// list rows, and body Japanese text where legibility at small sizes
    /// matters more than character.
    static func japaneseSans(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(sansPostScriptName(for: weight), size: size)
    }

    private static func minchoPostScriptName(for weight: Font.Weight) -> String {
        switch weight {
        case .semibold, .bold, .heavy, .black:
            return "HiraMinProN-W6"
        default:
            return "HiraMinProN-W3"
        }
    }

    private static func sansPostScriptName(for weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight, .thin:
            return "HiraginoSans-W0"
        case .light:
            return "HiraginoSans-W2"
        case .regular:
            return "HiraginoSans-W3"
        case .medium:
            return "HiraginoSans-W4"
        case .semibold:
            return "HiraginoSans-W6"
        case .bold:
            return "HiraginoSans-W7"
        case .heavy, .black:
            return "HiraginoSans-W8"
        default:
            return "HiraginoSans-W3"
        }
    }
}
