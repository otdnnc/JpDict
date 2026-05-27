import SwiftUI
import JpDict

struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @State private var selectedResultID: SearchResult.ID?

    init(dictionary: JpDictionary) {
        _viewModel = State(initialValue: SearchViewModel(dictionary: dictionary))
    }

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationTitle("JpDict")
                .searchable(
                    text: $viewModel.query,
                    placement: .sidebar,
                    prompt: Text("kanji, kana, or English")
                )
                .onChange(of: viewModel.query) { _, _ in
                    viewModel.performSearch()
                }
        } detail: {
            detail
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Search failed",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else if viewModel.isInitialState {
            IntroPlaceholder()
        } else if viewModel.isSearching && viewModel.results.isEmpty {
            SearchingPlaceholder()
        } else if viewModel.results.isEmpty {
            NoResultsPlaceholder(query: viewModel.trimmedQuery)
        } else {
            List(viewModel.results, selection: $selectedResultID) { result in
                SearchResultRow(result: result)
                    .tag(Optional(result.id))
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        if let id = selectedResultID,
           let result = viewModel.results.first(where: { $0.id == id }) {
            WordDetailView(searchResult: result)
        } else {
            DetailIntroPlaceholder(hasResults: !viewModel.results.isEmpty)
        }
    }
}
