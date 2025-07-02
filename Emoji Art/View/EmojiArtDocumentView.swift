//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 6/14/25.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State var zoom: CGFloat = 1.0
    @State var pan: CGOffset = .zero
    
    @GestureState var gestureZoom: CGFloat = 1.0
    @GestureState var gesturePan: CGOffset = .zero
    
    private let emojis = "👻🍎😀🤪☹️🤯🐶🐭🦁🐵🦆🐋🐝🐢🐄🐷🌲🍄🌞🔥🌈🦄☁️🌧️⛄️⛳️🚗🚘🚲🚀❤️";
    private let paletteEmojiSize: CGFloat = 40.0
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            paletteChooser
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: StringURLData.self) { data, location in
                return drop(data, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background)
            .position(Emoji.Position.origin.in(geometry))
        ForEach(document.emojis) { emoji in
            Text(emoji.emoji)
                .font(emoji.font)
                .position(emoji.position.in(geometry))
        }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { pinchScale, gestureZoom, transaction in  // inMotionPinchScale, _, _
                gestureZoom = pinchScale
            }
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { inMotionValue, gesturePan, transaction in
                gesturePan = inMotionValue.translation
            }
            .onEnded { endingValue in
                pan += endingValue.translation
            }
    }
    
    private var paletteChooser: some View {
        PaletteChooser()
            .font(.system(size: paletteEmojiSize))
            .padding(.horizontal)
            .scrollIndicators(.hidden)
    }
    
    private func drop(_ data: [StringURLData], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        guard let first = data.first else {
            return false
        }
        
        switch (first) {
        case .data:
            // pending
            return false
            
        case .string(let emoji):
            document.addEmoji(
                emoji,
                at: emojiPosition(at: location, in: geometry),
                size: paletteEmojiSize / zoom
            )
            return true
        
        case .url(let url):
            document.setBackground(url)
            return true
        }
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        let x = (location.x - center.x - pan.width) / zoom
        let y = (center.y - location.y + pan.height) / zoom
        return Emoji.Position(x: Int(x), y: Int(y))
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
}
