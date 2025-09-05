//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 6/14/25.
//

import CoreTransferable
import SwiftUI
import UniformTypeIdentifiers


class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
        }
    }
    
    private func autosave() {
        do {
            let data = try emojiArt.json()
            try data.write(to: documentURL)
            print("autosaved to \(documentURL)")
            
        } catch let error {
            print("Error saving emoji art document: \(error.localizedDescription)")
        }
    }
   
    var documentURL: URL {
        URL.documentsDirectory.appendingPathComponent("document.emojiart")
    }

    
    init() {
        // emojiArt.addEmoji("🤔", at: .init(x: 200, y: -100), size: 25)
        // emojiArt.addEmoji("🐋", at: .init(x: -150, y: 100), size: 50)
        
        if let data = try? Data(contentsOf: documentURL), let emojiArt = try? EmojiArt(json: data) {
            self.emojiArt = emojiArt
        }
    }
        
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var background: URL? {
        emojiArt.background
    }
    
    // MARK: Intents
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
    func moveEmoji(atIndex index: Int, to newPosition: Emoji.Position) {
        emojiArt.moveEmoji(atIndex: index, to: newPosition)
    }
    
    func resizeEmoji(atIndex index: Int, to newSize: Int) {
        emojiArt.resizeEmoji(atIndex: index, to: newSize)
    }
    
    func removeEmoji(atIndex index: Int) {
        emojiArt.removeEmoji(atIndex: index)
    }
}

extension EmojiArt.Emoji: Transferable {
    func font(scaleFactor: CGFloat) -> Font {
        let size = CGFloat(self.size) * scaleFactor
        return .system(size: size)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: EmojiArt.Emoji.self, contentType: .emoji)
    }
}

extension UTType {
    static var emoji = UTType(exportedAs: "com.nicholasdalba.emoji")
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        // MARK: Check this out later
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}

struct DummyError: LocalizedError {
    var errorDescription: String? { "oh no :o" }
}
