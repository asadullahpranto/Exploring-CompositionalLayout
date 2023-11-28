//
//  CollectionViewCell.swift
//  Exploring-CompositionalLayout
//
//  Created by Safe Tect on 28/11/23.
//

import UIKit

class AlbumItemCell: UICollectionViewCell {
    static let reuseIdentifier = "album-item-cell-reuse-id"
    
    let titleLabel = UILabel()
    let featuredPhotoView = UIImageView()
    let contentContainer = UIView()
    
    var title: String? {
        didSet {
            configure()
        }
    }
    
    var featuredPhotoUrl: URL? {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
}

extension AlbumItemCell {
    private func configure() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(featuredPhotoView)
        contentContainer.addSubview(contentContainer)
        
        featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
        if let featuredPhotoUrl = featuredPhotoUrl {
            featuredPhotoView.image = UIImage(contentsOfFile: featuredPhotoUrl.path)
        }
        featuredPhotoView.clipsToBounds = true
        contentContainer.addSubview(featuredPhotoView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowRadius = 3.0
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        titleLabel.layer.masksToBounds = false
        contentContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
    }
}
