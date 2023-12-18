//
//  PhotoDetailViewController.swift
//  Exploring-CompositionalLayout
//
//  Created by Bitmorpher 4 on 12/18/23.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    var photoURL: URL?
    let imageView = UIImageView()
    
    convenience init(photoURL: URL) {
        self.init()
        self.photoURL = photoURL;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoURL = photoURL {
            let imageName = photoURL.lastPathComponent
            navigationItem.title = imageName
            
            let image = UIImage(contentsOfFile: photoURL.path)
            imageView.image = image;
            imageView.contentMode = .scaleAspectFit
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            view.backgroundColor = .systemBackground
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                imageView.topAnchor.constraint(equalTo: view.topAnchor)
            ])
        }
    }
}
