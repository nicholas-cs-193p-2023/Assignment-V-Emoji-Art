//
//  PaletteStore.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 7/1/25.
//

import SwiftUI

extension UserDefaults {
    func palettes(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key), let palettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return palettes
        }
        return []
    }
    
    func set(_ palettes: [Palette], forKey key: String) {
        let jsonData = try? JSONEncoder().encode(palettes)
        set(jsonData, forKey: key)
    }
}

class PaletteStore: ObservableObject {
    let name: String
    
    init(named name: String) {
        self.name = name
        palettes = UserDefaults.standard.palettes(forKey: userDefaultsKey)
        if palettes.isEmpty {
            palettes = Palette.builtIns
            if palettes.isEmpty {
                palettes = [Palette(name: "Warning", emojis: "⚠️")]
            }
        }
    }
    
    var userDefaultsKey: String { "\(name):paletteStore" }
    
    var palettes: [Palette] {
        get {
            UserDefaults.standard.palettes(forKey: userDefaultsKey)
        } set {
            if newValue.isEmpty { return }
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
            objectWillChange.send()
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
