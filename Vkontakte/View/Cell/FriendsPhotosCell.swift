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
    
    private var photoService = PhotoService.instance
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
//    private func setupPhotoView(data: Photo, cell: FriendsPhotosCell, indexPath: IndexPath){
//        let stringURL = data.url
//        let imageCache = ImageCache.instance
//        cell.tag = indexPath.row
//        if let imageData = imageCache.cache[stringURL]{
//            self.photo.image = UIImage(data: imageData)
//            self.likeConrolView.isHidden = false
//            self.likeConrolView.heartButtonOnBar.isHidden = false
//            self.likeConrolView.labelLikeCount.text = String(data.likeCount)
//            self.likeConrolView.likeCount = data.likeCount
//            self.likeConrolView.userLikeCount = data.likeCount
//        } else {
//            DispatchQueue.global().async {
//                let imageData: Data = NetworkManager.shared.getImageData(stringURL: stringURL)
//                DispatchQueue.main.async {
//                    if cell.tag == indexPath.row{
//                        imageCache.cache[stringURL] = imageData
//                        self.photo.image = UIImage(data: imageData)
//                        self.likeConrolView.isHidden = false
//                        self.likeConrolView.heartButtonOnBar.isHidden = false
//                        self.likeConrolView.labelLikeCount.text = String(data.likeCount)
//                        self.likeConrolView.likeCount = data.likeCount
//                        self.likeConrolView.userLikeCount = data.likeCount
//                    }
//                }
//            }
//        }
//    }
    
    public func setupCell(data: Photo, cell: FriendsPhotosCell, indexPath: IndexPath){
        let stringURL = data.url
        self.photo.image = nil
        self.likeConrolView.labelLikeCount.text = nil
        self.likeConrolView.isHidden = true
        self.likeConrolView.heartButtonOnBar.isHidden = true
        cell.tag = indexPath.row
        if cell.tag == indexPath.row {
//          self.setupPhotoView(data: data, cell: cell, indexPath: indexPath)
            photoService.photo(stringURL: stringURL) {[weak self] (image) in
                DispatchQueue.main.async {
                    self?.photo.image = image
                    self?.likeConrolView.isHidden = false
                    self?.likeConrolView.heartButtonOnBar.isHidden = false
                    self?.likeConrolView.labelLikeCount.text = String(data.likeCount)
                    self?.likeConrolView.likeCount = data.likeCount
                    self?.likeConrolView.userLikeCount = data.likeCount
                }
            }
        }
    }
}

