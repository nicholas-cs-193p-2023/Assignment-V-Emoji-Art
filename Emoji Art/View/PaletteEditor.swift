//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 8/28/25.
//

import SwiftUI

struct PaletteEditor: View {
    private let emojiFont = Font.system(size: 40)
    
    @Binding var palette: Palette
    @State var emojisToAdd = ""
    @FocusState private var focused: Focus?

    private enum Focus {
        case name
        case addEmojis
    }
    
    var body: some View {
        Form {
            nameSection
            emojiSection
        }
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            } else {
                focused = .addEmojis
            }
        }
    }
    
    @ViewBuilder
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Set Palette's Name", text: $palette.name)
                .focused($focused, equals: .name)
        }
    }
    
    @ViewBuilder
    var emojiSection: some View {
        Section(header: Text("Emojis")) {
            TextField("Add Emojis Here", text: $emojisToAdd)
                .focused($focused, equals: .addEmojis)
                .font(emojiFont)
                .onChange(of: emojisToAdd) {
                    palette.emojis = (emojisToAdd + palette.emojis)
                        // .filter { $0.isEmoji }
                        .uniqued
                }
            emojiRemover
        }
    }
    
    @ViewBuilder
    var emojiRemover: some View {
        VStack(alignment: .trailing) {
            Text("Tap to remove emojis")
                .font(.caption)
                .foregroundStyle(.gray)
            ScrollView {
                emojiGrid
            }
        }
    }
    
    @ViewBuilder
    var emojiGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
            ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                Text(emoji)
                    .onTapGesture {
                        withAnimation {
                            guard let onlyEmoji = emoji.first else { return }
                            print("onlyEmoji: \(onlyEmoji)")
                            guard let paletteIndex = palette.emojis.firstIndex(where: { $0 == onlyEmoji }) else { return }
                            print("paletteIndex: \(paletteIndex)")
                            palette.emojis.remove(at: paletteIndex)
                            
                            emojisToAdd.removeAll(where: { $0 == onlyEmoji })
                        }
                    }
            }
        }
        .font(emojiFont)
    }
}

#Preview {
    PaletteEditorPreview()
}

private struct PaletteEditorPreview: View {
    // Could also have @StateObject var paletteStore,
    // and pass in $paletteStore.palette...
    @State var palette = Palette(name: "Trucks", emojis: "🚚🚒🛻")
    var body: some View {
        PaletteEditor(palette: $palette)
    }
}

