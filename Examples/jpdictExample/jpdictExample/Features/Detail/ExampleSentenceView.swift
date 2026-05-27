import SwiftUI
import JpDict

struct ExampleSentenceView: View {
    let example: Word.Example

    private var japanese: Word.Sentence? {
        example.sentences.first(where: { $0.lang == "jpn" }) ?? example.sentences.first
    }

    private var translations: [Word.Sentence] {
        guard let primaryLang = japanese?.lang else { return example.sentences }
        return example.sentences.filter { $0.lang != primaryLang }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let japanese {
                Text(highlighted(japanese.text))
                    .font(.japaneseSerif(size: 17))
                    .textSelection(.enabled)
            }
            ForEach(Array(translations.enumerated()), id: \.offset) { _, sentence in
                Text(sentence.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.4), in: .rect(cornerRadius: 12))
    }

    private func highlighted(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        guard !example.text.isEmpty,
              let range = attributed.range(of: example.text) else {
            return attributed
        }
        attributed[range].font = .japaneseSerif(size: 17, weight: .semibold)
        attributed[range].foregroundColor = .accentColor
        return attributed
    }
}
