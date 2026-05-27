import SwiftUI
import JpDict

struct WordDetailView: View {
    let searchResult: SearchResult
    @Environment(DictionaryStore.self) private var store

    @State private var word: Word?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
        }
        .navigationTitle(searchResult.kanji ?? searchResult.kana)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task(id: searchResult.id) {
            await load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let word {
            VStack(spacing: 20) {
                WordHeaderCard(word: word, fallback: searchResult)
                ForEach(Array(word.senses.enumerated()), id: \.offset) { index, sense in
                    SenseCard(index: index + 1, sense: sense)
                }
            }
        } else if isLoading {
            VStack(spacing: 12) {
                ProgressView().controlSize(.large)
                Text("Loading entry…")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 240)
        } else {
            ContentUnavailableView(
                "Couldn’t load entry",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage ?? "Unknown error")
            )
            .frame(minHeight: 240)
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        word = nil

        guard let dictionary = store.dictionary else {
            errorMessage = "Dictionary unavailable."
            isLoading = false
            return
        }

        let id = searchResult.id
        let fetchTask = Task.detached(priority: .userInitiated) {
            try dictionary.word(id: id)
        }

        do {
            let fetched = try await fetchTask.value
            word = fetched
            if fetched == nil { errorMessage = "No entry found for this word." }
        } catch {
            errorMessage = String(describing: error)
        }
        isLoading = false
    }
}
