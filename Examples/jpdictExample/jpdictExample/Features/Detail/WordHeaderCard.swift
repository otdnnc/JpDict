import SwiftUI
import JpDict

struct WordHeaderCard: View {
    let word: Word
    let fallback: SearchResult

    private var primaryKanji: String? {
        word.kanji.first?.text ?? fallback.kanji
    }

    private var primaryKana: String {
        word.kana.first?.text ?? fallback.kana
    }

    private var alternateKanji: [String] {
        Array(word.kanji.dropFirst()).map(\.text)
    }

    private var alternateKana: [String] {
        Array(word.kana.dropFirst()).map(\.text)
    }

    private var isCommon: Bool {
        word.kanji.first?.common == true || word.kana.first?.common == true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(primaryKanji ?? primaryKana)
                    .font(.japaneseSerif(size: 52, weight: .semibold))
                    .textSelection(.enabled)

                Spacer(minLength: 0)

                if isCommon {
                    TagChip(text: "Common", tint: .green)
                }
            }

            if primaryKanji != nil {
                Text(primaryKana)
                    .font(.japaneseSans(size: 20))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            if !alternateKanji.isEmpty {
                AlternateFormsRow(label: "Also written", values: alternateKanji)
            }

            if !alternateKana.isEmpty {
                AlternateFormsRow(label: "Also read", values: alternateKana)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
    }
}

private struct AlternateFormsRow: View {
    let label: String
    let values: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)

            FlowLayout(spacing: 6) {
                ForEach(values, id: \.self) { value in
                    Text(value)
                        .font(.japaneseSans(size: 14))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())
                }
            }
        }
    }
}
