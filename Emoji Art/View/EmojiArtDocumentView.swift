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
    @State var selectedEmojis: Set<Emoji.ID> = []
    
    @GestureState var gestureZoom: CGFloat = 1.0
    @GestureState var gesturePan: CGOffset = .zero
    @GestureState var gestureEmojiPan: CGOffset = .zero
    
    private let paletteEmojiSize: CGFloat = 40.0
    private let trashCanSize: CGFloat = 36.0
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            paletteChooser
        }
    }
    
    @ViewBuilder
    private var documentBody: some View {
        let zoom = self.zoom * (selectedEmojis.isEmpty ? gestureZoom : 1.0)
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture
                .simultaneously(with: zoomGesture)
                .simultaneously(with: tapGesture))
            .dropDestination(for: StringURLData.self) { data, location in
                return drop(data, at: location, in: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background) { phase in
            if let image = phase.image {
                image
            } else if let url = document.background {
                if phase.error != nil {
                    Text("\(url)")
                } else {
                    ProgressView()
                }
            }
        }
            .position(Emoji.Position.origin.in(geometry))
        ForEach(document.emojis) { emoji in
            onCanvasEmoji(emoji, in: geometry)
        }
    }
    
    // MARK: Might want to ask about the changing identity of the view here.
    
    @ViewBuilder
    private func onCanvasEmoji(_ emoji: Emoji, in geometry: GeometryProxy) -> some View {
        let position = emoji.position.in(geometry)
        let offset = selectedEmojis.contains(emoji.id) ? CGPoint(x: gestureEmojiPan.width, y: gestureEmojiPan.height) : .zero
        let scale = selectedEmojis.contains(emoji.id) ? gestureZoom : 1.0
        Text(emoji.emoji)
            .font(emoji.font(scaleFactor: scale))
            .border(selectedEmojis.contains(emoji.id) ? Color.cyan : Color.clear, width: 4.0)
            .position(position + offset)
            .onDrag {
                let provider = NSItemProvider()
                provider.register(emoji)
                return provider
            } preview: {
                Text(emoji.emoji)
            }.gesture(tapEmojiGesture(emoji)
                .simultaneously(with: dragEmojisGesture(in: geometry)))
    }
    
    private var paletteChooser: some View {
        HStack {
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
            Image(systemName: "trash")
                .font(.system(size: trashCanSize))
                .foregroundStyle(.red)
                .padding(.horizontal, 16)
                .dropDestination(for: Emoji.self) { emojis, _ in
                    drop(emojis)
                }
        }
    }
    
    private func tapEmojiGesture(_ emoji: Emoji) -> some Gesture {
        TapGesture().onEnded {
            let emojiSelected = selectedEmojis.contains(emoji.id)
            if emojiSelected {
                selectedEmojis.remove(emoji.id)
            } else {
                selectedEmojis.insert(emoji.id)
            }
        }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { pinchScale, gestureZoom, transaction in  // inMotionPinchScale, _, _
                gestureZoom = pinchScale
            }
            .onEnded { endingPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endingPinchScale
                } else {
                    updateEmojiSizes(endingPinchScale: endingPinchScale)
                }
            }
    }
    
    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis.removeAll()
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
    
    private func dragEmojisGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($gestureEmojiPan) { inMotionValue, gestureEmojiPan, transaction in
                gestureEmojiPan = inMotionValue.translation
            }
            .onEnded { endingValue in
                updateEmojiPositions(in: geometry, dragTranslation: endingValue.translation)
            }
    }
        
    private func updateEmojiSizes(endingPinchScale: CGFloat) {
        for selectedEmojiId in selectedEmojis {
            guard let selectedEmojiIndex = document.emojis.firstIndex(where: { $0.id == selectedEmojiId }) else {
                print("Couldn't find emoji with id: \(selectedEmojiId)")
                return
            }
            
            let newSize = endingPinchScale * CGFloat(document.emojis[selectedEmojiIndex].size)
            document.resizeEmoji(atIndex: selectedEmojiIndex, to: Int(newSize))
        }
    }
    
    private func updateEmojiPositions(in geometry: GeometryProxy, dragTranslation: CGOffset) {
        for selectedEmojiId in selectedEmojis {
            guard let selectedEmojiIndex = document.emojis.firstIndex(where: { $0.id == selectedEmojiId }) else {
                print("Couldn't find emoji with id: \(selectedEmojiId)")
                return
            }

            let selectedEmoji = document.emojis[selectedEmojiIndex]
            let imageCenter = imageCenter(in: geometry)
            let initialLocation = locationOf(selectedEmoji, withImageCenter: imageCenter)
            print("Initial Location: \(initialLocation)")
            
            let finalX = initialLocation.x + dragTranslation.width * zoom
            let finalY = initialLocation.y + dragTranslation.height * zoom
            let endLocation = CGPoint(x: finalX, y: finalY)
            
            let xPosition = (endLocation.x - imageCenter.x) / zoom
            let yPosition = (imageCenter.y - endLocation.y) / zoom
            print("xPosition, yPosition -> \(xPosition), \(yPosition)")
            
            let finalPosition = Emoji.Position(x: Int(xPosition), y: Int(yPosition))
            document.moveEmoji(atIndex: selectedEmojiIndex, to: finalPosition)
        }
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
    
    private func drop(_ emojis: [Emoji]) -> Bool {
        guard let emoji = emojis.first else { return false }
        guard let emojiIndex = document.emojis.firstIndex(where: {$0.id == emoji.id}) else { return false }
        
        document.removeEmoji(atIndex: emojiIndex)
        return true
    }
    
    private func locationOf(_ emoji: Emoji, withImageCenter imageCenter: CGPoint) -> CGPoint {
        print("Emoji Position: \(emoji.position)")
        
        let x = CGFloat(emoji.position.x) * zoom + imageCenter.x
        let y = imageCenter.y - CGFloat(emoji.position.y) * zoom
        return CGPoint(x: x, y: y)
    }
    
    private func imageCenter(in geometry: GeometryProxy) -> CGPoint {
        let frame = geometry.frame(in: .local)
        print("Dropped Frame: \(frame)")
        
        let imageWidth = frame.width * zoom
        let imageHeight = frame.height * zoom
        
        let xOffset = (frame.width - imageWidth) / 2
        let yOffset = (frame.height - imageHeight) / 2
       
        let centerX = xOffset + imageWidth / 2
        let centerY = yOffset + imageHeight / 2
        return CGPoint(x: centerX, y: centerY)
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
