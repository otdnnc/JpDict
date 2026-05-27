import Foundation

enum Cleanup {
    /// Removes intermediate download/extract artifacts once the SQLite db has
    /// been built. The tarball and JSON together are ~140 MB on disk and are
    /// no longer needed.
    static func removeIntermediates() {
        let fm = FileManager.default
        for path in [Paths.tarballPath, Paths.jsonPath] {
            guard fm.fileExists(atPath: path) else { continue }
            do {
                try fm.removeItem(atPath: path)
                print("• Removed \(path)")
            } catch {
                print("• Warning: could not remove \(path): \(error)")
            }
        }
    }
}
