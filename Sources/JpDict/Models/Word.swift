import Foundation

/// A fully-loaded dictionary entry, suitable for rendering a "word detail"
/// screen in a Japanese dictionary app.
///
/// Returned from ``JpDictionary/word(id:)``. Composed of one or more written
/// (kanji) forms, one or more spoken (kana) readings, and one or more
/// senses — each sense bundles its glosses with any attached Tatoeba example
/// sentences.
public struct Word: Sendable, Hashable {
    public let id: String
    public let kanji: [KanjiForm]
    public let kana: [KanaForm]
    public let senses: [Sense]

    public init(id: String, kanji: [KanjiForm], kana: [KanaForm], senses: [Sense]) {
        self.id = id
        self.kanji = kanji
        self.kana = kana
        self.senses = senses
    }

    public struct KanjiForm: Sendable, Hashable {
        public let text: String
        public let common: Bool
        public let tags: [String]

        public init(text: String, common: Bool, tags: [String]) {
            self.text = text
            self.common = common
            self.tags = tags
        }
    }

    public struct KanaForm: Sendable, Hashable {
        public let text: String
        public let common: Bool
        public let tags: [String]
        /// Kanji forms this reading applies to. `["*"]` means all forms.
        public let appliesToKanji: [String]

        public init(text: String, common: Bool, tags: [String], appliesToKanji: [String]) {
            self.text = text
            self.common = common
            self.tags = tags
            self.appliesToKanji = appliesToKanji
        }
    }

    public struct Sense: Sendable, Hashable {
        public let partOfSpeech: [String]
        public let field: [String]
        public let misc: [String]
        public let info: [String]
        public let glosses: [Gloss]
        public let examples: [Example]

        public init(
            partOfSpeech: [String],
            field: [String],
            misc: [String],
            info: [String],
            glosses: [Gloss],
            examples: [Example]
        ) {
            self.partOfSpeech = partOfSpeech
            self.field = field
            self.misc = misc
            self.info = info
            self.glosses = glosses
            self.examples = examples
        }
    }

    public struct Gloss: Sendable, Hashable {
        public let lang: String
        public let text: String
        /// e.g. "literal", "figurative", "explanation", "trademark".
        public let type: String?
        /// e.g. "masculine", "feminine", "neuter".
        public let gender: String?

        public init(lang: String, text: String, type: String?, gender: String?) {
            self.lang = lang
            self.text = text
            self.type = type
            self.gender = gender
        }
    }

    public struct Example: Sendable, Hashable {
        /// Source corpus identifier — currently always `"tatoeba"`.
        public let sourceType: String
        /// External ID inside the source corpus.
        public let sourceValue: String
        /// The dictionary form (kanji or kana) this example illustrates.
        public let text: String
        public let sentences: [Sentence]

        public init(sourceType: String, sourceValue: String, text: String, sentences: [Sentence]) {
            self.sourceType = sourceType
            self.sourceValue = sourceValue
            self.text = text
            self.sentences = sentences
        }
    }

    public struct Sentence: Sendable, Hashable {
        public let lang: String
        public let text: String

        public init(lang: String, text: String) {
            self.lang = lang
            self.text = text
        }
    }
}
