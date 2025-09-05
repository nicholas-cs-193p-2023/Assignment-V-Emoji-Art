//
//  PaletteList.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 9/3/25.
//

import SwiftUI

struct EditablePaletteList: View {
    @EnvironmentObject var store: PaletteStore
    @State private var showPaletteEditor = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(value: palette) {
                        VStack(alignment: .leading) {
                            Text(palette.name)
                            Text(palette.emojis).lineLimit(1)
                        }
                    }
                }
                .onMove { indexSet, dropIndex in
                    store.palettes.move(fromOffsets: indexSet, toOffset: dropIndex)
                }
                .onDelete { indexSet in
                    withAnimation {
                        store.palettes.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                if let index = store.palettes.firstIndex(where: { $0.id == palette.id }) {
                    PaletteEditor(palette: $store.palettes[index])
                }
            }
            .navigationDestination(isPresented: $showPaletteEditor) {
                PaletteEditor(palette: $store.palettes[store.cursorIndex])
            }
            .navigationTitle("\(store.name) Palettes")
            .toolbar {
                Button {
                    store.insert(Palette(name: "", emojis: ""))
                    showPaletteEditor = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        NavigationStack {
            List(store.palettes) { palette in
                NavigationLink(value: palette) {
                    Text(palette.name)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                PaletteView(palette)
            }
            .navigationTitle("\(store.name) Palettes")
        }
    }
}

struct PaletteView: View {
    var palette: Palette
    
    init(_ palette: Palette) {
        self.palette = palette
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size: 300))
            }
            Spacer()
        }
        .padding()
        .navigationTitle(palette.name)
        .font(.largeTitle)
    }
}
