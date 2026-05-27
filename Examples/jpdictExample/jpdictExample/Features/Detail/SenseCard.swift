import SwiftUI
import JpDict

struct SenseCard: View {
    let index: Int
    let sense: Word.Sense

    private var displayGlosses: [Word.Gloss] {
        let english = sense.glosses.filter { $0.lang == "eng" }
        return english.isEmpty ? sense.glosses : english
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            glossList
            if !sense.examples.isEmpty {
                Divider().opacity(0.4)
                examplesSection
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 22))
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("\(index)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 22, alignment: .leading)

            FlowLayout(spacing: 6) {
                ForEach(sense.partOfSpeech, id: \.self) { pos in
                    TagChip(text: pos, tint: .accentColor)
                }
                ForEach(sense.field, id: \.self) { field in
                    TagChip(text: field, tint: .purple)
                }
                ForEach(sense.misc, id: \.self) { misc in
                    TagChip(text: misc, tint: .orange)
                }
            }
        }
    }

    private var glossList: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(displayGlosses.enumerated()), id: \.offset) { _, gloss in
                Text(gloss.text)
                    .font(.body)
                    .textSelection(.enabled)
            }

            if !sense.info.isEmpty {
                Text(sense.info.joined(separator: " · "))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.leading, 32)
    }

    private var examplesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Examples")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)

            ForEach(Array(sense.examples.enumerated()), id: \.offset) { _, example in
                ExampleSentenceView(example: example)
            }
        }
        .padding(.leading, 32)
    }
}
