import Foundation
import GRDB
import JpDict

enum DatabaseBuilder {

    /// Decodes the extracted JSON and builds a fresh SQLite database at
    /// ``Paths.dbPath``. Any existing database at that path is overwritten.
    static func build() throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: Paths.dbPath) {
            try fm.removeItem(atPath: Paths.dbPath)
        }

        let dict = try decodeJSON()
        try writeDatabase(dict)
    }

    // MARK: - Decode

    private static func decodeJSON() throws -> JMdict {
        print("• Reading JSON (\(Paths.jsonPath))...")
        let data = try Data(contentsOf: URL(fileURLWithPath: Paths.jsonPath))
        print("  Decoding \(data.count / 1024 / 1024) MB...")
        let dict = try JSONDecoder().decode(JMdict.self, from: data)
        print("  Parsed \(dict.words.count) word entries.")
        return dict
    }

    // MARK: - Write

    private static func writeDatabase(_ dict: JMdict) throws {
        // Bulk-load with relaxed durability for speed; finalize with default
        // settings + VACUUM so the on-disk file is portable.
        var fastConfig = Configuration()
        fastConfig.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode = MEMORY")
            try db.execute(sql: "PRAGMA synchronous = OFF")
            try db.execute(sql: "PRAGMA temp_store = MEMORY")
        }
        let buildQueue = try DatabaseQueue(path: Paths.dbPath, configuration: fastConfig)
        print("• Building schema...")
        try buildQueue.write { db in
            try Schema.create(db)
            try insertMeta(db: db, dict: dict)
            try insertWords(db: db, words: dict.words)
        }
        try buildQueue.close()

        // VACUUM must run outside any transaction.
        let finalQueue = try DatabaseQueue(path: Paths.dbPath)
        try finalQueue.writeWithoutTransaction { db in
            try db.execute(sql: "VACUUM")
        }
        try finalQueue.close()
    }

    // MARK: - Inserts

    private static func insertMeta(db: Database, dict: JMdict) throws {
        let metaStmt = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.meta) (key, value) VALUES (?, ?)"
        )
        try metaStmt.execute(arguments: ["version", dict.version])
        try metaStmt.execute(arguments: ["languages", dict.languages.joined(separator: ",")])
        try metaStmt.execute(arguments: ["common_only", dict.commonOnly ? "1" : "0"])
        try metaStmt.execute(arguments: ["dict_date", dict.dictDate])
        try metaStmt.execute(arguments: ["dict_revisions", dict.dictRevisions.joined(separator: ",")])

        let tagStmt = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.tag) (tag, description) VALUES (?, ?)"
        )
        for (tag, description) in dict.tags {
            try tagStmt.execute(arguments: [tag, description])
        }
    }

    private static func insertWords(db: Database, words: [JMdict.Word]) throws {
        let stmts = try InsertStatements(db: db)
        let encoder = JSONEncoder()

        print("• Inserting \(words.count) words into SQLite...")
        let reportEvery = 20_000
        for (index, word) in words.enumerated() {
            try stmts.word.execute(arguments: [word.id])

            for (kIdx, kanji) in word.kanji.enumerated() {
                try stmts.kanji.execute(arguments: [
                    word.id, kIdx, kanji.text, kanji.common ? 1 : 0,
                    try encoder.jsonString(kanji.tags),
                ])
            }

            for (kIdx, kana) in word.kana.enumerated() {
                try stmts.kana.execute(arguments: [
                    word.id, kIdx, kana.text, kana.common ? 1 : 0,
                    try encoder.jsonString(kana.tags),
                    try encoder.jsonString(kana.appliesToKanji),
                ])
            }

            for (sIdx, sense) in word.sense.enumerated() {
                try stmts.sense.execute(arguments: [
                    word.id, sIdx,
                    try encoder.jsonString(sense.partOfSpeech),
                    try encoder.jsonString(sense.appliesToKanji),
                    try encoder.jsonString(sense.appliesToKana),
                    try encoder.jsonString(sense.related),
                    try encoder.jsonString(sense.antonym),
                    try encoder.jsonString(sense.field),
                    try encoder.jsonString(sense.dialect),
                    try encoder.jsonString(sense.misc),
                    try encoder.jsonString(sense.info),
                    try encoder.jsonString(sense.languageSource),
                ])
                let senseRowID = db.lastInsertedRowID
                for (gIdx, gloss) in sense.gloss.enumerated() {
                    try stmts.gloss.execute(arguments: [
                        senseRowID, gIdx, gloss.lang, gloss.gender, gloss.type, gloss.text,
                    ])
                }
                for (eIdx, example) in sense.examples.enumerated() {
                    try stmts.example.execute(arguments: [
                        senseRowID, eIdx,
                        example.source.type, example.source.value, example.text,
                    ])
                    let exampleRowID = db.lastInsertedRowID
                    for (sentIdx, sentence) in example.sentences.enumerated() {
                        try stmts.exampleSentence.execute(arguments: [
                            exampleRowID, sentIdx, sentence.lang, sentence.text,
                        ])
                    }
                }
            }

            if (index + 1) % reportEvery == 0 {
                print("  ... \(index + 1) / \(words.count)")
            }
        }
        print("  Inserted all \(words.count) words.")
    }
}

private struct InsertStatements {
    let word: Statement
    let kanji: Statement
    let kana: Statement
    let sense: Statement
    let gloss: Statement
    let example: Statement
    let exampleSentence: Statement

    init(db: Database) throws {
        word = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.word) (id) VALUES (?)"
        )
        kanji = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.kanji) (word_id, position, text, common, tags) VALUES (?, ?, ?, ?, ?)"
        )
        kana = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.kana) (word_id, position, text, common, tags, applies_to_kanji) VALUES (?, ?, ?, ?, ?, ?)"
        )
        sense = try db.makeStatement(sql: """
            INSERT INTO \(Schema.Table.sense) (
                word_id, position, part_of_speech, applies_to_kanji, applies_to_kana,
                related, antonym, field, dialect, misc, info, language_source
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """)
        gloss = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.gloss) (sense_id, position, lang, gender, type, text) VALUES (?, ?, ?, ?, ?, ?)"
        )
        example = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.example) (sense_id, position, source_type, source_value, text) VALUES (?, ?, ?, ?, ?)"
        )
        exampleSentence = try db.makeStatement(
            sql: "INSERT INTO \(Schema.Table.exampleSentence) (example_id, position, lang, text) VALUES (?, ?, ?, ?)"
        )
    }
}

private extension JSONEncoder {
    func jsonString<T: Encodable>(_ value: T) throws -> String {
        let data = try encode(value)
        return String(decoding: data, as: UTF8.self)
    }
}
