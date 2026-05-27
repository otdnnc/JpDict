import Foundation
import Testing
@testable import JpDict

/// Smoke tests that exercise the public API against a real `jpdict.sqlite`.
///
/// The whole suite is `.enabled(if:)`-gated on the database existing at the
/// package root, so a fresh checkout still builds green. Build the db with
/// `swift run jpdict-prepare` to enable these locally.
@Suite(
    "JpDictionary smoke tests",
    .enabled(if: smokeTestDatabaseExists, "Run `swift run jpdict-prepare` first")
)
struct JpDictionarySmokeTests {

    @Test func searchByEnglishGloss() throws {
        let dict = try openDictionary()
        let results = try dict.search("hello", limit: 10)
        #expect(!results.isEmpty)
        #expect(results.count <= 10)
        #expect(results.allSatisfy { !$0.kana.isEmpty })
    }

    @Test func searchByKana() throws {
        let dict = try openDictionary()
        let results = try dict.search("たべる", limit: 5)
        #expect(!results.isEmpty)
        // Exact kana match is rank 1, so the top hit's primary reading should
        // equal the query.
        #expect(results.first?.kana == "たべる")
    }

    @Test func wordDetailLoadsExamples() throws {
        let dict = try openDictionary()
        // 1000110 → ＣＤプレーヤー — the first entry in the file with an
        // attached Tatoeba example.
        let word = try #require(try dict.word(id: "1000110"))
        #expect(!word.kanji.isEmpty)
        #expect(!word.kana.isEmpty)
        #expect(!word.senses.isEmpty)

        let allExamples = word.senses.flatMap(\.examples)
        #expect(!allExamples.isEmpty, "1000110 should have at least one example sentence")

        let firstExample = try #require(allExamples.first)
        #expect(firstExample.sourceType == "tatoeba")
        #expect(firstExample.sentences.count >= 2) // jpn + eng minimum
    }

    @Test func wordDetailReturnsNilForUnknownID() throws {
        let dict = try openDictionary()
        #expect(try dict.word(id: "0000000") == nil)
    }

    // MARK: - Helpers

    private func openDictionary() throws -> JpDictionary {
        try JpDictionary(path: smokeTestDatabasePath)
    }
}

// MARK: - Suite-level fixtures

/// Path to `jpdict.sqlite` at the package root. `#filePath` points at this
/// source file inside `Tests/JpDictTests/`; pop two levels to reach the root.
private let smokeTestDatabasePath: String = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("jpdict.sqlite")
    .path

private var smokeTestDatabaseExists: Bool {
    FileManager.default.fileExists(atPath: smokeTestDatabasePath)
}
