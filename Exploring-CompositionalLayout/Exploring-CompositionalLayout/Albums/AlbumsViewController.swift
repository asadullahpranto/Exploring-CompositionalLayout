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
        
        self.navigationItem.title = "My Albums"
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
        collectionView.register(FeaturedAlbumItemCell.self, forCellWithReuseIdentifier: FeaturedAlbumItemCell.reuseIdentifer)
        collectionView.register(SharedAlbumItemCell.self, forCellWithReuseIdentifier: SharedAlbumItemCell.reuseIdentifer)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: AlbumsViewController.sectionHeaderElementKind, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        albumsCollectionView = collectionView
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, AlbumItem>(collectionView: albumsCollectionView, cellProvider: { (collectionView: UICollectionView, indexPath: IndexPath, albumItem: AlbumItem) -> UICollectionViewCell? in
            
            let sectionType = Section.allCases[indexPath.section]
            switch sectionType {
            case .featuredAlbums:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedAlbumItemCell.reuseIdentifer, for: indexPath) as? FeaturedAlbumItemCell else { return UICollectionViewCell()}
                
                cell.featuredPhotoURL = albumItem.imageItems[0].thumbnailUrl
                cell.title = albumItem.albumTitle
                cell.totalNumberOfImages = albumItem.imageItems.count
                return cell
                
            case .sharedAlbums:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharedAlbumItemCell.reuseIdentifer, for: indexPath) as? SharedAlbumItemCell else { return UICollectionViewCell() }
                
                cell.featuredPhotoURL = albumItem.imageItems[0].thumbnailUrl
                cell.title = albumItem.albumTitle
                return cell
                
            case .myAlbums:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumItemCell.reuseIdentifier, for: indexPath) as? AlbumItemCell else { return UICollectionViewCell() }
                cell.featuredPhotoUrl = albumItem.imageItems[0].thumbnailUrl
                cell.title = albumItem.albumTitle
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView,
                                                  kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else {
                return UICollectionReusableView()
            }
            
            supplementaryView.label.text = Section.allCases[indexPath.section].rawValue
            return supplementaryView
            
        }
        
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500
            
            let sectionLayoutKind = Section.allCases[sectionIndex]
            switch sectionLayoutKind {
                
            case .featuredAlbums:
                return self.generateFeaturedAlbumsLayout(isWide: isWideView)
            case .sharedAlbums:
                return self.generateSharedlbumsLayout()
            case .myAlbums:
                return self.generateMyAlbumsLayout(isWide: isWideView)
            }
        }
        
        return layout
    }
    
    private func generateMyAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(isWide ? 0.25 : 0.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeight
        )
    
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isWide ? 4 : 2)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: AlbumsViewController.sectionHeaderElementKind, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0)

        return section
    }
    
    private func generateFeaturedAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/3)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupFractionWidth = isWide ? 0.475 : 0.95
        let groupFractionHeight: CGFloat = isWide ? 1/3 : 2/3
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupFractionWidth),
            heightDimension: .fractionalWidth(groupFractionHeight)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: AlbumsViewController.sectionHeaderElementKind, alignment: .top)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    private func generateSharedlbumsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(140),
            heightDimension: .absolute(186))
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 5,
            leading: 5,
            bottom: 5,
            trailing: 5)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: AlbumsViewController.sectionHeaderElementKind,
            alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        
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
