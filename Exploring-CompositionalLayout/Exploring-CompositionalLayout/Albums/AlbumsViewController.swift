//
//  AlbumsViewController.swift
//  Exploring-CompositionalLayout
//
//  Created by Bitmorpher 4 on 12/18/23.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AlbumItem>! = nil
    var albumsCollectionView: UICollectionView! = nil
    
    enum Section: String, CaseIterable {
        case featuredAlbums = "Featured Ablums"
        case sharedAlbums = "Shared Albums"
        case myAlbums = "My Albums"
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
        dataSource = UICollectionViewDiffableDataSource<Section, AlbumItem>(collectionView: albumsCollectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, albumItem: AlbumItem) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumItemCell.reuseIdentifier, for: indexPath) as? AlbumItemCell else { fatalError("can not create new cell") }
            cell.featuredPhotoUrl = albumItem.imageItems[0].thumbnailUrl
            cell.title = albumItem.albumTitle
            return cell
        })
        
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500
            
            return self.generateMyAlbumsLayout(isWide: isWideView)
        }
        
        return layout
    }
    
    func generateMyAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(isWide ? 0.25 : 0.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isWide ? 4 : 2)

        let section = NSCollectionLayoutSection(group: group)

        return section
    }
    
    private func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlbumItem> {
        let allAlbums =  albumsInBaseDirectory()
        let sharingSuggestions = Array(albumsInBaseDirectory().prefix(3))
        let sharedAlbums = Array(albumsInBaseDirectory().suffix(3))
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AlbumItem>()
        snapshot.appendSections([.featuredAlbums])
        snapshot.appendItems(sharingSuggestions)
        
        snapshot.appendSections([.sharedAlbums])
        snapshot.appendItems(sharedAlbums)
        
        snapshot.appendSections([.myAlbums])
        snapshot.appendItems(allAlbums)
        
        return snapshot
    }
    
    private func albumsInBaseDirectory() -> [AlbumItem] {
        guard let baseUrl = baseUrl else { return [] }
        
        let fileManager = FileManager.default
        
        do {
            return try fileManager.albumsAtUrl(baseUrl)
        } catch {
            print(error)
            return []
        }
    }

}

extension AlbumsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let albumDetailVC = AlbumDetailViewController(withPhotosFromDirectory: item.albumUrl)
        navigationController?.pushViewController(albumDetailVC, animated: true)
    }
}
