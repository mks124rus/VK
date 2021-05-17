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
    
    func setupCell(data: Photo, cell: FriendsPhotosCell, indexPath: IndexPath){
        let stringURL = data.url
        self.likeConrolView.labelLikeCount.text = nil
        self.likeConrolView.isHidden = true
        self.likeConrolView.heartButtonOnBar.isHidden = true
        self.photo.image = nil
        cell.tag = indexPath.row
        DispatchQueue.global().async {
            let imageData: Data = NetworkManager.shared.getImageData(stringURL: stringURL)
            DispatchQueue.main.async {
                if cell.tag == indexPath.row{
                    self.photo.image = UIImage(data: imageData)
                    self.likeConrolView.isHidden = false
                    self.likeConrolView.heartButtonOnBar.isHidden = false
                    self.likeConrolView.labelLikeCount.text = String(data.likeCount)
                    self.likeConrolView.likeCount = data.likeCount
                    self.likeConrolView.userLikeCount = data.likeCount
                }
            }
        }
    }
}

