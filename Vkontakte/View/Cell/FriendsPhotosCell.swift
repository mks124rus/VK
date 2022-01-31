//
//  FriendsPhotosCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 24.02.2021.
//

import UIKit

class FriendsPhotosCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var likeControlView: LikeControl!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var loadIcon: UIImageView!

    private var photoService = PhotoService.instance
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photo.image = nil
    }
    
    lazy private var tapGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTouchesRequired = 1
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(doubleTapForLike))
        recognizer.delegate = self
        return recognizer
    }()

    @objc func doubleTapForLike(_ sender: UITapGestureRecognizer){
        likeControlView.addUndoLike()
        print("tap")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addGestureRecognizer(tapGesture)
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
        
        self.framePhoto()
        self.frameLikeControlView()
        self.frameLoadIcon()
    }
    
    private func frameLoadIcon(){
        let sideIconLenght: CGFloat = 40
        let size = CGSize(width: sideIconLenght, height: sideIconLenght)
        let origin = CGPoint(x: bounds.midX - sideIconLenght/2, y: bounds.midY - sideIconLenght/2)
        self.loadIcon.frame = CGRect(origin: origin, size: size)
    }
    
    private func framePhoto(){
        let width = self.bounds.width
        let height = self.bounds.height
        let size = CGSize(width: width, height: height)
        let orign = CGPoint(x: 0, y: 0)
        self.photo.frame = CGRect(origin: orign, size: size)
    }
    
    private func frameLikeControlView(){
        let width = photo.frame.width
        let height = (self.bounds.width * 20)/100
        let size = CGSize(width: width, height: height)
        let originX = bounds.minX
        let originY = bounds.maxY - height
        let origin = CGPoint(x: originX, y: originY)
        self.likeControlView.frame = CGRect(origin: origin, size: size)
        self.likeControlView.setupFrameView(middleY: bounds.midY)
    }
    
    public func setupCell(data: Photo, cell: FriendsPhotosCell, indexPath: IndexPath){
        let stringURL = data.url
        self.likeControlView.labelLikeCount.text = nil
        self.likeControlView.isHidden = true
        self.likeControlView.heartButtonOnBar.isHidden = true
        cell.tag = indexPath.row
        if cell.tag == indexPath.row {
//          self.setupPhotoView(data: data, cell: cell, indexPath: indexPath)
            photoService.photo(stringURL: stringURL) {[weak self] (image) in
                DispatchQueue.main.async {
                    self?.photo.image = image
                    self?.likeControlView.isHidden = false
                    self?.likeControlView.heartButtonOnBar.isHidden = false
                    self?.likeControlView.labelLikeCount.text = String(data.likeCount)
                    self?.likeControlView.likeCount = data.likeCount
                    self?.likeControlView.userLikeCount = data.likeCount
                }
            }
        }
    }
}

