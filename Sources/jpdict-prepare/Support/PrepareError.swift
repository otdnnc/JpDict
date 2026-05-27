import Foundation

enum PrepareError: Error, CustomStringConvertible {
    case downloadFailed(status: Int)
    case extractionFailed(status: Int32)
    case extractedFileMissing(expected: String)

    var description: String {
        switch self {
        case .downloadFailed(let status):
            return "Download failed with HTTP status \(status). The signed URL may have expired — replace `Paths.downloadURL` or drop a fresh tarball at `Paths.tarballPath`."
        case .extractionFailed(let status):
            return "tar exited with status \(status)."
        case .extractedFileMissing(let expected):
            return "Expected extracted file not found at \(expected)."
        }
    }
}
