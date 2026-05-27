import Foundation
import Observation
import JpDict

@MainActor
@Observable
final class SearchViewModel {

    var query: String = ""
    private(set) var results: [SearchResult] = []
    private(set) var isSearching: Bool = false
    private(set) var errorMessage: String?

    private let dictionary: JpDictionary
    private var currentTask: Task<Void, Never>?
    private let debounce: Duration = .milliseconds(180)
    private let resultLimit = 50

    init(dictionary: JpDictionary) {
        self.dictionary = dictionary
    }

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isInitialState: Bool {
        trimmedQuery.isEmpty && results.isEmpty && !isSearching && errorMessage == nil
    }

    func performSearch() {
        currentTask?.cancel()

        let trimmed = trimmedQuery
        guard !trimmed.isEmpty else {
            results = []
            errorMessage = nil
            isSearching = false
            return
        }

        let dictionary = self.dictionary
        let debounce = self.debounce
        let limit = self.resultLimit

        currentTask = Task { [weak self] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled, let self else { return }

            self.isSearching = true

            let fetchTask = Task.detached(priority: .userInitiated) {
                try dictionary.search(trimmed, limit: limit)
            }

            do {
                let fetched = try await fetchTask.value
                guard !Task.isCancelled else { return }
                self.results = fetched
                self.errorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                self.errorMessage = String(describing: error)
            }
            self.isSearching = false
        }
    }
}
