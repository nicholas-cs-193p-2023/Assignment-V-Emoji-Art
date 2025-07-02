//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 6/14/25.
//

import Foundation

typealias Emoji = EmojiArt.Emoji

struct EmojiArt {
    var background: URL? {
        didSet {
            print("Background is now \(String(describing: background))")
        }
    }
    private(set) var emojis: [Emoji] = []

    private var emojiCount = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        emojis.append(Emoji(
            emoji: emoji,
            position: position,
            size: size,
            id: emojiCount
        ))
        emojiCount += 1
    }
    
    struct Emoji: Identifiable {
        let emoji: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let origin = Self(x: 0, y: 0)
        }
    }
}
