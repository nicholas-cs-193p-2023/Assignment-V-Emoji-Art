//
//  StringURLData.swift
//  Emoji Art
//
//  Created by Nicholas Alba on 6/25/25.
//

import CoreTransferable

enum StringURLData: Transferable {
    case string(String)
    case url(URL)
    case data(Data)
        
    init(string: String) {
        if string.starts(with: "http"), let url = URL(string: string) {
            self = .url(url)
        } else {
            self = .string(string)
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { StringURLData(string: $0) }
        ProxyRepresentation { StringURLData.url($0) }
        ProxyRepresentation { StringURLData.data($0) }
    }
}
