import SwiftUI

struct RootView: View {
    @Environment(DictionaryStore.self) private var store

    var body: some View {
        switch store.state {
        case .loading:
            LoadingPlaceholder()
        case .ready(let dictionary):
            SearchView(dictionary: dictionary)
        case .failed(let error):
            FailurePlaceholder(error: error)
        }
    }
}
