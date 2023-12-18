//
//  PhotoItemCell.swift
//  Exploring-CompositionalLayout
//
//  Created by Bitmorpher 4 on 12/18/23.
//

import UIKit

class PhotoItemCell: UICollectionViewCell {
    static let reuseIdentifer = "photo-item-cell-reuse-identifier"
    let imageView = UIImageView()
    let contentContainer = UIView()
    
    var photoURL: URL? {
        didSet {
            configure()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoItemCell {
    func configure() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentContainer)
        
        guard let photoURL = self.photoURL else { return };
        let photo = UIImage(contentsOfFile: photoURL.path)
        imageView.image = photo
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor)
        ])
    }
}
