//
//  GridViewCell.swift
//  MINTEL_LiveChat
//
//  Created by Autthapon Sukjaroen on 13/8/2563 BE.
//

import UIKit
 
class GridViewCell: UICollectionViewCell {
 
    var imageView: UIImageView = UIImageView()
    var livePhotoBadgeImageView: UIImageView = UIImageView()
 
    var representedAssetIdentifier: String!
 
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    var livePhotoBadgeImage: UIImage! {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        livePhotoBadgeImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.size.width, height: self.contentView.bounds.size.height)
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(livePhotoBadgeImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
