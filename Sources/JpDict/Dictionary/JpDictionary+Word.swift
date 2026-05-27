import Foundation
import GRDB

extension JpDictionary {

    /// Loads the full entry for the given word ID — all kanji forms, kana
    /// readings, senses, glosses, and Tatoeba example sentences.
    ///
    /// - Returns: the entry, or `nil` if no word exists with that ID.
    public func word(id: String) throws -> Word? {
        try dbQueue.read { db in
            guard try wordExists(db: db, id: id) else { return nil }

            return Word(
                id: id,
                kanji: try loadKanji(db: db, wordID: id),
                kana: try loadKana(db: db, wordID: id),
                senses: try loadSenses(db: db, wordID: id)
            )
        }
    }

    // MARK: - Private

    private func wordExists(db: Database, id: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS(SELECT 1 FROM \(Schema.Table.word) WHERE id = ?)",
            arguments: [id]
        ) ?? false
    }

    private func loadKanji(db: Database, wordID: String) throws -> [Word.KanjiForm] {
        let rows = try Row.fetchAll(db, sql: """
            SELECT text, common, tags
            FROM \(Schema.Table.kanji)
            WHERE word_id = ?
            ORDER BY position
            """, arguments: [wordID])
        return rows.map { row in
            Word.KanjiForm(
                text: row["text"],
                common: (row["common"] as Int) != 0,
                tags: decodeJSONArray(row["tags"])
            )
        }
    }

    private func loadKana(db: Database, wordID: String) throws -> [Word.KanaForm] {
        let rows = try Row.fetchAll(db, sql: """
            SELECT text, common, tags, applies_to_kanji
            FROM \(Schema.Table.kana)
            WHERE word_id = ?
            ORDER BY position
            """, arguments: [wordID])
        return rows.map { row in
            Word.KanaForm(
                text: row["text"],
                common: (row["common"] as Int) != 0,
                tags: decodeJSONArray(row["tags"]),
                appliesToKanji: decodeJSONArray(row["applies_to_kanji"])
            )
        }
    }

    private func loadSenses(db: Database, wordID: String) throws -> [Word.Sense] {
        let senseRows = try Row.fetchAll(db, sql: """
            SELECT id, part_of_speech, field, misc, info
            FROM \(Schema.Table.sense)
            WHERE word_id = ?
            ORDER BY position
            """, arguments: [wordID])

        return try senseRows.map { row in
            let senseID: Int64 = row["id"]
            return Word.Sense(
                partOfSpeech: decodeJSONArray(row["part_of_speech"]),
                field: decodeJSONArray(row["field"]),
                misc: decodeJSONArray(row["misc"]),
                info: decodeJSONArray(row["info"]),
                glosses: try loadGlosses(db: db, senseID: senseID),
                examples: try loadExamples(db: db, senseID: senseID)
            )
        }
    }

    private func loadGlosses(db: Database, senseID: Int64) throws -> [Word.Gloss] {
        let rows = try Row.fetchAll(db, sql: """
            SELECT lang, text, type, gender
            FROM \(Schema.Table.gloss)
            WHERE sense_id = ?
            ORDER BY position
            """, arguments: [senseID])
        return rows.map { row in
            Word.Gloss(
                lang: row["lang"],
                text: row["text"],
                type: row["type"],
                gender: row["gender"]
            )
        }
    }

    private func loadExamples(db: Database, senseID: Int64) throws -> [Word.Example] {
        let exampleRows = try Row.fetchAll(db, sql: """
            SELECT id, source_type, source_value, text
            FROM \(Schema.Table.example)
            WHERE sense_id = ?
            ORDER BY position
            """, arguments: [senseID])

        return try exampleRows.map { row in
            let exampleID: Int64 = row["id"]
            return Word.Example(
                sourceType: row["source_type"],
                sourceValue: row["source_value"],
                text: row["text"],
                sentences: try loadSentences(db: db, exampleID: exampleID)
            )
        }
    }

    private func loadSentences(db: Database, exampleID: Int64) throws -> [Word.Sentence] {
        let rows = try Row.fetchAll(db, sql: """
            SELECT lang, text
            FROM \(Schema.Table.exampleSentence)
            WHERE example_id = ?
            ORDER BY position
            """, arguments: [exampleID])
        return rows.map { Word.Sentence(lang: $0["lang"], text: $0["text"]) }
    }

    private func decodeJSONArray(_ text: String) -> [String] {
        guard let data = text.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }
}
