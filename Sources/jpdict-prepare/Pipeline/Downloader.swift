import Foundation

enum Downloader {
    /// Downloads the JMdict-simplified tarball to ``Paths.tarballPath``.
    /// Skips the network call if the file is already present.
    static func downloadIfNeeded() async throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: Paths.tarballPath) {
            print("• Tarball already present at \(Paths.tarballPath)")
            return
        }

        print("• Downloading tarball from GitHub release assets...")
        let (tempURL, response) = try await URLSession.shared.download(from: Paths.downloadURL)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            try? fm.removeItem(at: tempURL)
            throw PrepareError.downloadFailed(status: http.statusCode)
        }

        let destination = URL(fileURLWithPath: Paths.tarballPath)
        try? fm.removeItem(at: destination)
        try fm.moveItem(at: tempURL, to: destination)
        print("  Saved to \(Paths.tarballPath)")
    }
}
