import SwiftUI

struct LoadingPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView().controlSize(.large)
            Text("Loading dictionary…")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FailurePlaceholder: View {
    let error: any Error

    var body: some View {
        ContentUnavailableView(
            "Couldn’t open dictionary",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }
}

struct IntroPlaceholder: View {
    var body: some View {
        ContentUnavailableView(
            "Search the dictionary",
            systemImage: "magnifyingglass",
            description: Text("Type a kanji, kana reading, or English word.")
        )
    }
}

struct SearchingPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Searching…")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoResultsPlaceholder: View {
    let query: String

    var body: some View {
        ContentUnavailableView(
            "No results",
            systemImage: "magnifyingglass",
            description: Text("Nothing matched “\(query)”. Try a different word.")
        )
    }
}

struct DetailIntroPlaceholder: View {
    let hasResults: Bool

    var body: some View {
        ContentUnavailableView(
            hasResults ? "Pick a word" : "Start searching",
            systemImage: hasResults ? "hand.point.up.left" : "character.book.closed.ja",
            description: Text(hasResults
                ? "Select an entry from the list to see its full details."
                : "Search any kanji, kana, or English term to see results.")
        )
    }
}
