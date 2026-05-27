import SwiftUI
import JpDict

struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                if let kanji = result.kanji {
                    Text(kanji)
                        .font(.japaneseSans(size: 20, weight: .semibold))
                    Text(result.kana)
                        .font(.japaneseSans(size: 15))
                        .foregroundStyle(.secondary)
                } else {
                    Text(result.kana)
                        .font(.japaneseSans(size: 20, weight: .semibold))
                }
            }

            if !result.glosses.isEmpty {
                Text(result.glosses.joined(separator: " • "))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
