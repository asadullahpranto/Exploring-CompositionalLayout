//
//  ViewController.swift
//  Exploring-CompositionalLayout
//
//  Created by Safe Tect on 28/11/23.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AlbumItem>! = nil
    
    var albumsCollectionView: UICollectionView! = nil
    
    enum Section: String, CaseIterable {
        case featuredAlbum = "Featured Ablums"
        case sharedAlbum = "Shared Albums"
        case myAlbum = "My Albums"
    }
    
    var baseUrl: URL?
    
    convenience init(withAlbumsFromDirectory directory: URL) {
        self.init()
        
        baseUrl = directory
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Your Albums"
        configureCollectionView()
        configureDataSource()
    }
    
    private func configureCollectionView() {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(AlbumItemCell.self, forCellWithReuseIdentifier: AlbumItemCell.reuseIdentifier)
        
        albumsCollectionView = collectionView
    }
    
    private func configureDataSource() {
        let dataSource = UICollectionViewDiffableDataSource<Section, AlbumItem>(collectionView: albumsCollectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, albumItem: AlbumItem) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumItemCell.reuseIdentifier, for: indexPath) as? AlbumItemCell else { fatalError("can not create new cell") }
            cell.featuredPhotoUrl = albumItem.imageItems[0].thumbnailUrl
            cell.title = albumItem.albumTitle
            return cell
        })
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        
    }


}

extension AlbumsViewController: UICollectionViewDelegate {
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
//    let albumDetailVC = AlbumDetailViewController(withPhotosFromDirectory: item.albumURL)
//    navigationController?.pushViewController(albumDetailVC, animated: true)
//  }
}

