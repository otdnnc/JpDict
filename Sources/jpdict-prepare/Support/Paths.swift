import Foundation

/// Hardcoded inputs and outputs for the `jpdict-prepare` pipeline.
///
/// We use the jmdict-examples tarball — it's a superset of plain JMdict
/// (same word IDs, plus an `examples` array on each sense), so one download
/// gives us both the dictionary and Tatoeba example sentences.
///
/// All artifacts (tarball, extracted JSON, SQLite db) are written next to
/// wherever `swift run jpdict-prepare` is invoked — typically the package root.
enum Paths {
    static let downloadURL = URL(string: "https://github.com/scriptin/jmdict-simplified/releases/download/3.6.2%2B20260525143653/jmdict-examples-eng-3.6.2+20260525143653.json.tgz")!

    static let tarballName = "jmdict-examples-eng-3.6.2+20260525143653.json.tgz"
    static let jsonName = "jmdict-examples-eng-3.6.2.json"
    static let dbName = "jpdict.sqlite"

    static var workingDir: String { FileManager.default.currentDirectoryPath }

    static var tarballPath: String { join(workingDir, tarballName) }
    static var jsonPath: String { join(workingDir, jsonName) }
    static var dbPath: String { join(workingDir, dbName) }

    private static func join(_ dir: String, _ component: String) -> String {
        (dir as NSString).appendingPathComponent(component)
    }
}
