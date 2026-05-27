import Foundation
import Observation
import JpDict

@MainActor
@Observable
final class DictionaryStore {

    enum LoadState {
        case loading
        case ready(JpDictionary)
        case failed(LoadError)
    }

    enum LoadError: LocalizedError {
        case bundleResourceMissing
        case openFailed(String)

        var errorDescription: String? {
            switch self {
            case .bundleResourceMissing:
                return "The dictionary database (jpdict.sqlite) is missing from the app bundle."
            case .openFailed(let message):
                return "Could not open the dictionary database: \(message)"
            }
        }
    }

    private(set) var state: LoadState = .loading

    init() {
        Task { await load() }
    }

    var dictionary: JpDictionary? {
        if case .ready(let dict) = state { return dict }
        return nil
    }

    private func load() async {
        let outcome: Result<JpDictionary, LoadError> = await Task.detached(priority: .userInitiated) {
            guard let url = Bundle.main.url(forResource: "jpdict", withExtension: "sqlite") else {
                return .failure(.bundleResourceMissing)
            }
            do {
                let dict = try JpDictionary(path: url.path)
                return .success(dict)
            } catch {
                return .failure(.openFailed(String(describing: error)))
            }
        }.value

        switch outcome {
        case .success(let dict):
            state = .ready(dict)
        case .failure(let error):
            state = .failed(error)
        }
    }
}
