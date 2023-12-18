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
        
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: fullPhotoItem, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        
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
