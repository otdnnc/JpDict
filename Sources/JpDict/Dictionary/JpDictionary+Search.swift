import Foundation
import GRDB

extension JpDictionary {

    /// Searches the dictionary by kanji form, kana reading, or English gloss
    /// and returns the top `limit` matches.
    ///
    /// Ranking, best-first:
    ///   1. exact kanji match
    ///   2. exact kana match
    ///   3. kanji prefix match
    ///   4. kana prefix match
    ///   5. English gloss prefix match
    ///
    /// - Parameters:
    ///   - query: User input. Empty strings return no results.
    ///   - limit: Maximum number of results to return. Defaults to 50.
    public func search(_ query: String, limit: Int = 50) throws -> [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, limit > 0 else { return [] }

        let prefix = "\(escapeLikePattern(trimmed))%"

        return try dbQueue.read { db in
            let ids = try matchingWordIDs(db: db, query: trimmed, prefix: prefix, limit: limit)
            return try ids.map { try buildSearchResult(db: db, wordID: $0) }
        }
    }

    // MARK: - Private

    private func matchingWordIDs(
        db: Database,
        query: String,
        prefix: String,
        limit: Int
    ) throws -> [String] {
        // Rank matches across all candidate columns, then keep the best rank
        // per word so that an exact-kanji hit always wins over a gloss prefix.
        let sql = """
            SELECT word_id
            FROM (
              SELECT word_id, MIN(rank) AS rank
              FROM (
                SELECT word_id, 1 AS rank FROM \(Schema.Table.kanji) WHERE text = ?
                UNION ALL
                SELECT word_id, 2          FROM \(Schema.Table.kana)  WHERE text = ?
                UNION ALL
                SELECT word_id, 3          FROM \(Schema.Table.kanji) WHERE text LIKE ? ESCAPE '\\' AND text != ?
                UNION ALL
                SELECT word_id, 4          FROM \(Schema.Table.kana)  WHERE text LIKE ? ESCAPE '\\' AND text != ?
                UNION ALL
                SELECT s.word_id, 5        FROM \(Schema.Table.gloss) g
                  JOIN \(Schema.Table.sense) s ON g.sense_id = s.id
                  WHERE g.text LIKE ? ESCAPE '\\'
              )
              GROUP BY word_id
              ORDER BY rank, word_id
              LIMIT ?
            )
            """
        return try String.fetchAll(db, sql: sql, arguments: [
            query, query,
            prefix, query,
            prefix, query,
            prefix,
            limit,
        ])
    }

    private func buildSearchResult(db: Database, wordID: String) throws -> SearchResult {
        let kanji = try String.fetchOne(
            db,
            sql: "SELECT text FROM \(Schema.Table.kanji) WHERE word_id = ? ORDER BY position LIMIT 1",
            arguments: [wordID]
        )
        let kana = try String.fetchOne(
            db,
            sql: "SELECT text FROM \(Schema.Table.kana) WHERE word_id = ? ORDER BY position LIMIT 1",
            arguments: [wordID]
        ) ?? ""

        let glosses = try String.fetchAll(db, sql: """
            SELECT g.text
            FROM \(Schema.Table.gloss) g
            JOIN \(Schema.Table.sense) s ON g.sense_id = s.id
            WHERE s.word_id = ? AND s.position = 0
            ORDER BY g.position
            LIMIT 3
            """, arguments: [wordID])

        return SearchResult(id: wordID, kanji: kanji, kana: kana, glosses: glosses)
    }

    /// Escapes user-supplied LIKE wildcards so a literal `_` or `%` in the
    /// query doesn't widen the match. Pair with `ESCAPE '\\'` in SQL.
    private func escapeLikePattern(_ input: String) -> String {
        input
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }
}
