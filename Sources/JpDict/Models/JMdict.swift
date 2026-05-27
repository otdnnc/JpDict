import Foundation

// Mirrors the jmdict-simplified 3.6.x JSON schema:
// https://github.com/scriptin/jmdict-simplified
//
// Lives in the JpDict library so both the `prepare` executable (which decodes
// the upstream JSON) and downstream consumers can share a single source of
// truth for the dictionary entry shape.

public struct JMdict: Codable, Sendable {
    public let version: String
    public let languages: [String]
    public let commonOnly: Bool
    public let dictDate: String
    public let dictRevisions: [String]
    public let tags: [String: String]
    public let words: [Word]

    public struct Word: Codable, Sendable {
        public let id: String
        public let kanji: [Kanji]
        public let kana: [Kana]
        public let sense: [Sense]
    }

    public struct Kanji: Codable, Sendable {
        public let common: Bool
        public let text: String
        public let tags: [String]
    }

    public struct Kana: Codable, Sendable {
        public let common: Bool
        public let text: String
        public let tags: [String]
        public let appliesToKanji: [String]
    }

    public struct Sense: Codable, Sendable {
        public let partOfSpeech: [String]
        public let appliesToKanji: [String]
        public let appliesToKana: [String]
        public let related: [[XrefElement]]
        public let antonym: [[XrefElement]]
        public let field: [String]
        public let dialect: [String]
        public let misc: [String]
        public let info: [String]
        public let languageSource: [LanguageSource]
        public let gloss: [Gloss]
        /// Tatoeba example sentences. Present in `jmdict-examples-*` tarballs;
        /// empty (or absent) in plain `jmdict-*` tarballs.
        public let examples: [Example]

        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            partOfSpeech = try c.decode([String].self, forKey: .partOfSpeech)
            appliesToKanji = try c.decode([String].self, forKey: .appliesToKanji)
            appliesToKana = try c.decode([String].self, forKey: .appliesToKana)
            related = try c.decode([[XrefElement]].self, forKey: .related)
            antonym = try c.decode([[XrefElement]].self, forKey: .antonym)
            field = try c.decode([String].self, forKey: .field)
            dialect = try c.decode([String].self, forKey: .dialect)
            misc = try c.decode([String].self, forKey: .misc)
            info = try c.decode([String].self, forKey: .info)
            languageSource = try c.decode([LanguageSource].self, forKey: .languageSource)
            gloss = try c.decode([Gloss].self, forKey: .gloss)
            examples = try c.decodeIfPresent([Example].self, forKey: .examples) ?? []
        }
    }

    public struct Example: Codable, Sendable {
        public let source: ExampleSource
        /// The dictionary form (kanji or kana) that this example illustrates.
        public let text: String
        public let sentences: [ExampleSentence]
    }

    public struct ExampleSource: Codable, Sendable {
        /// Currently always "tatoeba".
        public let type: String
        /// External ID inside the source corpus (e.g. a Tatoeba sentence ID).
        public let value: String
    }

    public struct ExampleSentence: Codable, Sendable {
        public let lang: String
        public let text: String
    }

    public struct LanguageSource: Codable, Sendable {
        public let lang: String
        public let full: Bool
        public let wasei: Bool
        public let text: String?
    }

    public struct Gloss: Codable, Sendable {
        public let lang: String
        public let gender: String?
        public let type: String?
        public let text: String
    }

    // Xref elements are heterogeneous: ["word", "reading", senseIndex]
    // where each slot is optional and senseIndex is an Int.
    public enum XrefElement: Codable, Sendable {
        case string(String)
        case integer(Int)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Int.self) {
                self = .integer(value)
                return
            }
            if let value = try? container.decode(String.self) {
                self = .string(value)
                return
            }
            throw DecodingError.typeMismatch(
                XrefElement.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Expected String or Int")
            )
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value): try container.encode(value)
            case .integer(let value): try container.encode(value)
            }
        }
    }
}
