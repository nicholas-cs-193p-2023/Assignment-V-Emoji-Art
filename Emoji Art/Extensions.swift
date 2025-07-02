//
//  Extensions.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 6/15/25.
//

import SwiftUI

typealias CGOffset = CGSize

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
    
    /*
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0, width: size.width, height: size.height)
    }
     */
    
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension CGOffset {
    static func +(left: CGOffset, right: CGOffset) -> CGOffset {
        let width = left.width + right.width
        let height = left.height + right.height
        return CGOffset(width: width, height: height)
    }
    
    static func +=(left: inout CGOffset, right: CGOffset) {
        left = left + right
    }
}

extension AnyTransition {
    static let rollUp: AnyTransition = .asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top))
    
    static let rollDown: AnyTransition = .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom))
}

struct AnimatedActionButton: View {
    var title: String?
    var systemImage: String?
    var role: ButtonRole?
    let action: () -> Void
    
    init(_ title: String? = nil, systemImage: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                action()
            }
        } label: {
            if let title, let systemImage {
                Label(title, systemImage: systemImage)
            } else if let title {
                Text(title)
            } else if let systemImage {
                Image(systemName: systemImage)
            }
        }
    }
}

extension String {
    var uniqued: String {
        var seen: Set<String> = []
        var uniqued: [String] = []
        
        for char in self {
            let character = String(char)
            if seen.contains(character) {
                continue
            }
            uniqued.append(character)
            seen.insert(character)
        }
        
        return uniqued.joined()
    }
}
