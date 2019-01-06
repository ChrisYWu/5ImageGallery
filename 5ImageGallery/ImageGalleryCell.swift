//
//  ImageGalleryCell.swift
//  5ImageGallery
//
//  Created by Chris Wu on 1/5/19.
//  Copyright © 2019 Wu Personal Team. All rights reserved.
//

import UIKit

class ImageGalleryCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    
    var imageItem: ImageItem? {
        didSet {
            setupImage()
        }
    }
    
    private func setupImage() {
        if let url = imageItem?.url {
            spiner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContent = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContent, url == self?.imageItem?.url {
                        self?.imageView.image = UIImage(data: imageData)
                        self?.spiner.stopAnimating()
                    }
                }
            }
        }
    }
    
}
