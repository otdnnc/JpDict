import Foundation

enum Extractor {
    /// Extracts ``Paths.tarballPath`` into ``Paths.downloadsDir`` via `/usr/bin/tar`.
    /// Skips when ``Paths.jsonPath`` already exists.
    static func extractIfNeeded() throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: Paths.jsonPath) {
            print("• JSON already extracted at \(Paths.jsonPath)")
            return
        }

        print("• Extracting tarball...")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        process.arguments = ["-xzf", Paths.tarballPath, "-C", Paths.workingDir]
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw PrepareError.extractionFailed(status: process.terminationStatus)
        }
        guard fm.fileExists(atPath: Paths.jsonPath) else {
            throw PrepareError.extractedFileMissing(expected: Paths.jsonPath)
        }
        print("  Extracted to \(Paths.jsonPath)")
    }
}
