//
//  FileManager+Extensions.swift
//  Exploring-CompositionalLayout
//
//  Created by Safe Tect on 29/11/23.
//

import Foundation

extension FileManager {
    func albumsAtUrl(_ fileUrl: URL) throws -> [AlbumItem] {
        let albumsArray = try self.contentsOfDirectory(
            at: fileUrl,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: .skipsHiddenFiles
        ).filter { (url) -> Bool in
            do {
                let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
                return resourceValues.isDirectory! && url.lastPathComponent.first != "_"
            } catch {
                return false
            }
        }.sorted(by: { (urlA, urlB) -> Bool in
            do {
                let nameA = try urlA.resourceValues(forKeys: [.nameKey]).name
                let nameB = try urlB.resourceValues(forKeys: [.nameKey]).name
                return nameA! < nameB!
            } catch {
                return true
            }
        })
        
        return albumsArray.map { fileUrl -> AlbumItem in
            do {
                let detailItems = try self.albumDetailItemsAtURL(fileUrl)
                return AlbumItem(albumUrl: fileUrl, imageItems: detailItems)
            } catch {
                return AlbumItem(albumUrl: fileUrl)
            }
        }
    }
    
    func albumDetailItemsAtURL(_ fileURL: URL) throws -> [AlbumDetailItem] {
      guard let components = URLComponents(url: fileURL, resolvingAgainstBaseURL: false) else { return [] }

      let photosArray = try self.contentsOfDirectory(
        at: fileURL,
        includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
        options: .skipsHiddenFiles
      ).filter { (url) -> Bool in
        do {
          let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
          return !resourceValues.isDirectory!
        } catch { return false }
      }.sorted(by: { (urlA, urlB) -> Bool in
        do {
          let nameA = try urlA.resourceValues(forKeys:[.nameKey]).name
          let nameB = try urlB.resourceValues(forKeys: [.nameKey]).name
          return nameA! < nameB!
        } catch { return true }
      })

      return photosArray.map { fileURL in AlbumDetailItem(
        photoUrl: fileURL,
        thumbnailUrl: URL(fileURLWithPath: "\(components.path)thumbs/\(fileURL.lastPathComponent)")
        )}
    }
}
