import Foundation
import GRDB

/// SQLite schema for the JMdict-derived dictionary.
///
/// Tables are normalized one level: every JMdict entry expands into rows in
/// `word` (id only), `kanji`, `kana`, `sense`, and `gloss`. Heterogeneous
/// fields (tags, xrefs, language sources) are persisted as JSON strings to
/// keep the schema compact while remaining queryable via SQLite's JSON1
/// functions.
public enum Schema {

    public enum Table {
        public static let meta = "meta"
        public static let tag = "tag"
        public static let word = "word"
        public static let kanji = "kanji"
        public static let kana = "kana"
        public static let sense = "sense"
        public static let gloss = "gloss"
        public static let example = "example"
        public static let exampleSentence = "example_sentence"
    }

    public static func create(_ db: Database) throws {
        try db.execute(sql: """
            CREATE TABLE \(Table.meta) (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            ) WITHOUT ROWID;
            """)

        try db.execute(sql: """
            CREATE TABLE \(Table.tag) (
                tag TEXT PRIMARY KEY,
                description TEXT NOT NULL
            ) WITHOUT ROWID;
            """)

        try db.execute(sql: """
            CREATE TABLE \(Table.word) (
                id TEXT PRIMARY KEY
            ) WITHOUT ROWID;
            """)

        try db.execute(sql: """
            CREATE TABLE \(Table.kanji) (
                id INTEGER PRIMARY KEY,
                word_id TEXT NOT NULL REFERENCES \(Table.word)(id),
                position INTEGER NOT NULL,
                text TEXT NOT NULL,
                common INTEGER NOT NULL,
                tags TEXT NOT NULL
            );
            """)
        try db.execute(sql: "CREATE INDEX kanji_word_idx ON \(Table.kanji)(word_id);")
        try db.execute(sql: "CREATE INDEX kanji_text_idx ON \(Table.kanji)(text);")

        try db.execute(sql: """
            CREATE TABLE \(Table.kana) (
                id INTEGER PRIMARY KEY,
                word_id TEXT NOT NULL REFERENCES \(Table.word)(id),
                position INTEGER NOT NULL,
                text TEXT NOT NULL,
                common INTEGER NOT NULL,
                tags TEXT NOT NULL,
                applies_to_kanji TEXT NOT NULL
            );
            """)
        try db.execute(sql: "CREATE INDEX kana_word_idx ON \(Table.kana)(word_id);")
        try db.execute(sql: "CREATE INDEX kana_text_idx ON \(Table.kana)(text);")

        try db.execute(sql: """
            CREATE TABLE \(Table.sense) (
                id INTEGER PRIMARY KEY,
                word_id TEXT NOT NULL REFERENCES \(Table.word)(id),
                position INTEGER NOT NULL,
                part_of_speech TEXT NOT NULL,
                applies_to_kanji TEXT NOT NULL,
                applies_to_kana TEXT NOT NULL,
                related TEXT NOT NULL,
                antonym TEXT NOT NULL,
                field TEXT NOT NULL,
                dialect TEXT NOT NULL,
                misc TEXT NOT NULL,
                info TEXT NOT NULL,
                language_source TEXT NOT NULL
            );
            """)
        try db.execute(sql: "CREATE INDEX sense_word_idx ON \(Table.sense)(word_id);")

        try db.execute(sql: """
            CREATE TABLE \(Table.gloss) (
                id INTEGER PRIMARY KEY,
                sense_id INTEGER NOT NULL REFERENCES \(Table.sense)(id),
                position INTEGER NOT NULL,
                lang TEXT NOT NULL,
                gender TEXT,
                type TEXT,
                text TEXT NOT NULL
            );
            """)
        try db.execute(sql: "CREATE INDEX gloss_sense_idx ON \(Table.gloss)(sense_id);")
        try db.execute(sql: "CREATE INDEX gloss_text_idx ON \(Table.gloss)(text);")

        try db.execute(sql: """
            CREATE TABLE \(Table.example) (
                id INTEGER PRIMARY KEY,
                sense_id INTEGER NOT NULL REFERENCES \(Table.sense)(id),
                position INTEGER NOT NULL,
                source_type TEXT NOT NULL,
                source_value TEXT NOT NULL,
                text TEXT NOT NULL
            );
            """)
        try db.execute(sql: "CREATE INDEX example_sense_idx ON \(Table.example)(sense_id);")

        try db.execute(sql: """
            CREATE TABLE \(Table.exampleSentence) (
                id INTEGER PRIMARY KEY,
                example_id INTEGER NOT NULL REFERENCES \(Table.example)(id),
                position INTEGER NOT NULL,
                lang TEXT NOT NULL,
                text TEXT NOT NULL
            );
            """)
        try db.execute(sql: "CREATE INDEX example_sentence_example_idx ON \(Table.exampleSentence)(example_id);")
    }
}
