//
//  AlbumDetailItem.swift
//  Exploring-CompositionalLayout
//
//  Created by Safe Tect on 28/11/23.
//

import Foundation

class AlbumDetailItem: Hashable {
    private let indentifier = UUID()
    
    let photoUrl: URL
    let thumbnailUrl: URL
    let subitems: [AlbumDetailItem]
    
    init(photoUrl: URL, thumbnailUrl: URL, subitems: [AlbumDetailItem] = []) {
        self.photoUrl = photoUrl
        self.thumbnailUrl = thumbnailUrl
        self.subitems = subitems
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(indentifier)
    }
    
    static func == (lhs: AlbumDetailItem, rhs: AlbumDetailItem) -> Bool {
        return lhs.indentifier == rhs.indentifier
    }
}
