import SwiftUI

struct SearchBar: View {
    @Binding var query: String
    var placeholder: String
    var onSubmit: (String) -> Void
    var onClear: () -> Void
    var history: [String]
    var onHistorySelection: (String) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $query)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .onSubmit { onSubmit(query) }

                if !query.isEmpty {
                    Button {
                        query = ""
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.regular.interactive(), in: .capsule)
            .overlay(
                Capsule()
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .designCodeShadow(.normal, colorScheme: colorScheme)
            .onChange(of: isFocused) { _, focused in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded = focused
                }
            }

            if !history.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(history, id: \.self) { term in
                            Button {
                                onHistorySelection(term)
                            } label: {
                                Text(term)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.thinMaterial, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 6)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: history)
    }
}

#if DEBUG
#Preview {
    SearchBar(
        query: .constant(""),
        placeholder: "Search",
        onSubmit: { _ in },
        onClear: {},
        history: ["Hydrogen", "Helium"],
        onHistorySelection: { _ in }
    )
    .padding()
}
#endif
