//
//  PostProfileCollectionViewCell.swift
//  TikTokClone
//
//  Created by apple on 01.09.2023.
//

import UIKit

protocol PostProfileCollectionViewCellDelegate: AnyObject {
    func goToDetailVC(postid: String)
}

class PostProfileCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PostProfileCollectionViewCellDelegate?
    
    @IBOutlet weak var postImage: UIImageView!
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        guard let postThumbnailImageUrl = post!.imageUrl else {return}
        
        self.postImage.loadImage(postThumbnailImageUrl)
        
        let tapGesturerorPhoto = UITapGestureRecognizer(target: self, action: #selector (self.postTouchUpInside))
        postImage.addGestureRecognizer(tapGesturerorPhoto)
        postImage.isUserInteractionEnabled = true
    }
    @objc func postTouchUpInside(){
        if let id = post?.postid {
            delegate?.goToDetailVC(postid: id)
        }
    }
}


