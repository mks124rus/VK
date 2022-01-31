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
    @IBOutlet weak var loadIcon: UIImageView!
    
    private var photoService = PhotoService.instance
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frameLikeControlView()
        self.frameLoadIcon()
    }
    
    private func frameLoadIcon(){
        let sideIconLenght: CGFloat = 40
        let size = CGSize(width: sideIconLenght, height: sideIconLenght)
        let origin = CGPoint(x: bounds.midX - sideIconLenght/2, y: bounds.midY - sideIconLenght/2)
        self.loadIcon.frame = CGRect(origin: origin, size: size)
    }
    
    private func frameLikeControlView(){
        let width = bounds.width
        let height: CGFloat = 20.0
        let size = CGSize(width: width, height: height)
        let originX = bounds.minX
        let originY = bounds.maxY - height
        let origin = CGPoint(x: originX, y: originY)
        self.likeConrolView.frame = CGRect(origin: origin, size: size)
    }
    
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

