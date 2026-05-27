import Foundation
import GRDB

/// Read-only handle to a JpDict SQLite database produced by `jpdict-prepare`.
///
/// Open once at app launch and keep it alive — the underlying GRDB queue
/// serializes access for you, so you can call ``search(_:limit:)`` and
/// ``word(id:)`` concurrently from any thread.
///
/// ```swift
/// let dict = try JpDictionary(path: "/path/to/jpdict.sqlite")
/// let results = try dict.search("食べる", limit: 20)
/// let detail = try dict.word(id: results[0].id)
/// ```
public final class JpDictionary: Sendable {

    /// GRDB queue. Internal to the module so search/detail extensions can
    /// reach it, but never exposed to consumers.
    let dbQueue: DatabaseQueue

    /// Opens the dictionary at the given file path in read-only mode.
    ///
    /// - Throws: ``Error/databaseMissing(_:)`` if no file exists at `path`,
    ///   or a GRDB error if the file is not a valid SQLite database.
    public init(path: String) throws {
        guard FileManager.default.fileExists(atPath: path) else {
            throw Error.databaseMissing(path)
        }
        var config = Configuration()
        config.readonly = true
        self.dbQueue = try DatabaseQueue(path: path, configuration: config)
    }

    /// Closes the underlying database file. Optional — the queue closes
    /// automatically when the last reference is released.
    public func close() throws {
        try dbQueue.close()
    }

    public enum Error: Swift.Error, CustomStringConvertible {
        case databaseMissing(String)

        public var description: String {
            switch self {
            case .databaseMissing(let path):
                return "No dictionary database found at \(path). Run `swift run jpdict-prepare` to build one."
            }
        }
    }
}
