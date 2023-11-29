//
//  AlbumItem.swift
//  Exploring-CompositionalLayout
//
//  Created by Safe Tect on 28/11/23.
//

import Foundation

class AlbumItem: Hashable {
    private let identifier = UUID()
    
    let albumUrl: URL
    let albumTitle: String
    let imageItems: [AlbumDetailItem]
    
    init(albumUrl: URL, imageItems: [AlbumDetailItem] = []) {
        self.albumUrl = albumUrl
        self.albumTitle = albumUrl.lastPathComponent.displayNicely
        self.imageItems = imageItems
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
