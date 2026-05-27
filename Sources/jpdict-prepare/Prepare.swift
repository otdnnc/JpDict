import Foundation

/// Entry point for `swift run jpdict-prepare`.
///
/// Orchestrates the pipeline stages:
///   1. ``Downloader`` — fetch the jmdict-simplified tarball.
///   2. ``Extractor`` — gunzip + untar to the source JSON.
///   3. ``DatabaseBuilder`` — decode JSON and build a SQLite database with GRDB.
///   4. ``Cleanup`` — delete the tarball + JSON now that the db exists.
@main
struct Prepare {
    static func main() async throws {
        try await Downloader.downloadIfNeeded()
        try Extractor.extractIfNeeded()
        try DatabaseBuilder.build()
        Cleanup.removeIntermediates()

        print("")
        print("✓ Done. SQLite database saved to:")
        print("  \(Paths.dbPath)")
    }
}
