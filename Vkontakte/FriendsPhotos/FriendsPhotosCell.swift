//
//  FriendsPhotosCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 24.02.2021.
//

import UIKit

class FriendsPhotosCell: UICollectionViewCell {
    
    @IBOutlet weak var likeConrolView: LikeControl!
    @IBOutlet weak var photo: UIImageView!
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
