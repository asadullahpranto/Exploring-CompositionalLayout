//
//  AlbumDetailViewController.swift
//  Exploring-CompositionalLayout
//
//  Created by Bitmorpher 4 on 12/18/23.
//

import UIKit

class AlbumDetailViewController: UIViewController {
    static let syncingBadgeKind = "syncing-badge-kind"
    
    enum Section {
        case albumBody
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AlbumDetailItem>! = nil
    var albumDetailCollectionView: UICollectionView! = nil
    
    var albumURL: URL?
    
    convenience init(withPhotosFromDirectory directory: URL) {
        self.init()
        albumURL = directory
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = albumURL?.lastPathComponent.displayNicely
        configureCollectionView()
        configureDataSource()
    }
}

extension AlbumDetailViewController {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: PhotoItemCell.reuseIdentifer)
        collectionView.register(SyncingBadgeView.self, forSupplementaryViewOfKind: AlbumDetailViewController.syncingBadgeKind, withReuseIdentifier: SyncingBadgeView.reuseIdentifier)
        albumDetailCollectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
        <Section, AlbumDetailItem>(collectionView: albumDetailCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, detailItem: AlbumDetailItem) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoItemCell.reuseIdentifer,
                for: indexPath) as? PhotoItemCell else { fatalError("Could not create new cell") }
            cell.photoURL = detailItem.thumbnailUrl
            return cell
        }
        
        dataSource.supplementaryViewProvider = {(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            if let badgeView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SyncingBadgeView.reuseIdentifier, for: indexPath) as? SyncingBadgeView {
                let hasSyncBadge = indexPath.row % Int.random(in: 1...6) == 0
                badgeView.isHidden = !hasSyncBadge
                return badgeView
            } else {
                return UICollectionReusableView()
            }
        }
        
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let syncingBadgeAnchor = NSCollectionLayoutAnchor(
            edges: [.top, .trailing],
            fractionalOffset: CGPoint(x: -0.3, y: 0.3))
        let syncingBadge = NSCollectionLayoutSupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(20),
                heightDimension: .absolute(20)),
            elementKind: AlbumDetailViewController.syncingBadgeKind,
            containerAnchor: syncingBadgeAnchor
        )
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/3))
        let fullPhotoItem = NSCollectionLayoutItem(
            layoutSize: itemSize,
            supplementaryItems: [syncingBadge])
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
        let mainItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(2/3),
            heightDimension: .fractionalHeight(1.0))
        let mainItem = NSCollectionLayoutItem(layoutSize: mainItemSize)
        mainItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let pairItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5))
        let pairItem = NSCollectionLayoutItem(layoutSize: pairItemSize)
        pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let pairGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0))
        
        let pairGroup = NSCollectionLayoutGroup.vertical(layoutSize: pairGroupSize, subitem: pairItem, count: 2)
        
        let mainWithPairItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(4/9))
        
        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairItemSize, subitems: [mainItem, pairGroup])
        
        let tripletSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0))
        let tripletItem = NSCollectionLayoutItem(layoutSize: tripletSize)
        tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let tripletGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/9))
        
        let tripletGroup = NSCollectionLayoutGroup.horizontal(layoutSize: tripletGroupSize, subitems: [tripletItem, tripletItem, tripletItem])
        
        let pairWithMainGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(4/9)),
            subitems: [pairGroup, mainItem])
        let nestedGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(16/9)),
            subitems: [fullPhotoItem, mainWithPairGroup, tripletGroup, pairWithMainGroup])
        
        let section = NSCollectionLayoutSection(group: nestedGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlbumDetailItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AlbumDetailItem>()
        snapshot.appendSections([Section.albumBody])
        let items = itemsForAlbum()
        snapshot.appendItems(items)
        return snapshot
    }
    
    func itemsForAlbum() -> [AlbumDetailItem] {
        guard let albumURL = albumURL else { return [] }
        let fileManager = FileManager.default
        do {
            return try fileManager.albumDetailItemsAtURL(albumURL)
        } catch {
            print(error)
            return []
        }
    }
}

extension AlbumDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let photoDetailVC = PhotoDetailViewController(photoURL: item.photoUrl)
        navigationController?.pushViewController(photoDetailVC, animated: true)
    }
}
