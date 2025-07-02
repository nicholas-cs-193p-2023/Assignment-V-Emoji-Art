//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 7/1/25.
//

import SwiftUI

class PaletteStore: ObservableObject {
    init(named name: String) {
        self.name = name
        palettes = Palette.builtIns
        if palettes.isEmpty {
            palettes = [Palette(name: "Warning", emojis: "⚠️")]
        }
    }
    
    let name: String
    @Published var palettes: [Palette] {
        didSet {
            if palettes.isEmpty, !oldValue.isEmpty {
                palettes = oldValue
            }
        }
    }
        
    var cursorIndex: Int {
        get { boundsCheckedPaletteIndex(_cursorIndex) }
        set { _cursorIndex = boundsCheckedPaletteIndex(newValue) }
    }
    
    // MARK: Adding Palettes
    // These functions are the recommended way to add Palettes to the PaletteStore
    // since they try to avoid duplication of Identifiable-y identical Palettes
    // by first removing/replacing any Palette with the same id that is already in palettes.
    // It does not remedy existing duplication, it just does not cause new duplication.
    
    func insert(_ palette: Palette, at insertionIndex: Int? = nil) {
        let insertionIndex = boundsCheckedPaletteIndex(insertionIndex ?? cursorIndex)
        guard let indexOfIdenticalPalette = palettes.firstIndex(where: { $0.id == palette.id }) else {
            palettes.insert(palette, at: insertionIndex)
            return
        }
        
        palettes.move(fromOffsets: IndexSet([indexOfIdenticalPalette]), toOffset: insertionIndex)
        palettes.replaceSubrange(insertionIndex...insertionIndex, with: [palette])
    }
    
    func insert(name: String, emojis: String, at index: Int? = nil) {
        insert(Palette(name: name, emojis: emojis), at: index)
    }
    
    func append(_ palette: Palette) {
        guard let indexOfIdenticalPalette = palettes.firstIndex(where: { $0.id == palette.id }) else {
            palettes.append(palette)
            return
        }
        
        if palettes.count > 1 {
            palettes.remove(at: indexOfIdenticalPalette)
            palettes.append(palette)
        } else {
            palettes = [palette]
        }
    }
    
    // MARK: Private Implementation
    
    @Published var _cursorIndex = 0
    
    private func boundsCheckedPaletteIndex(_ cursorIndex: Int) -> Int {
        var index = cursorIndex % palettes.count
        if index < 0 {
            index += palettes.count
        }
        return index
    }
}
