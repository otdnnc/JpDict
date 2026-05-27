import Foundation

/// Lightweight result row returned from ``JpDictionary/search(_:limit:)``,
/// suitable for rendering a search-results list.
///
/// Holds just enough to draw a row: the primary written form, the primary
/// reading, and the first sense's glosses. Fetch the full entry with
/// ``JpDictionary/word(id:)`` when the user picks a row.
public struct SearchResult: Sendable, Hashable, Identifiable {
    public let id: String
    /// Primary kanji form, or `nil` for kana-only words (e.g. katakana loanwords).
    public let kanji: String?
    /// Primary kana reading. Always present.
    public let kana: String
    /// First sense's glosses (English by default), capped — typically the
    /// 1–3 most-relevant translations.
    public let glosses: [String]

    public init(id: String, kanji: String?, kana: String, glosses: [String]) {
        self.id = id
        self.kanji = kanji
        self.kana = kana
        self.glosses = glosses
    }
}
