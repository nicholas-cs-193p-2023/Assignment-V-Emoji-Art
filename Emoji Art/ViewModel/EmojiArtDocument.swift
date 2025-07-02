//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 6/14/25.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private var emojiArt = EmojiArt()
        
    init() {
        emojiArt.addEmoji("🤔", at: .init(x: 200, y: -100), size: 50)
        emojiArt.addEmoji("🐋", at: .init(x: -150, y: 100), size: 100)
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
}

extension EmojiArt.Emoji {
    var font: Font {
        .system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        // MARK: Check this out later
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
