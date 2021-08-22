//
//  MyFriendsCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 27.02.2021.
//

import UIKit

class MyFriendsCell: UITableViewCell {
    @IBOutlet weak private var friendNameLabel: UILabel!
    @IBOutlet weak private var friendAvatarView: AvatarView!
    
    private let photoService = PhotoService.instance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.friendNameLabel.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let friendAvatarViewGesture = UITapGestureRecognizer(target: self, action: #selector(friendAvatarAnimate))
        friendAvatarView.addGestureRecognizer(friendAvatarViewGesture)
        
    }
    
//    private func setAndCacheLogo(data: User){
//        let imageCache = ImageCache.instance
//        let avatarURL = data.avatar
//
//        if let data = imageCache.cache[avatarURL] {
//            self.friendAvatarView.image = UIImage(data: data)
//        } else {
//            DispatchQueue.global(qos: .userInteractive).async {
//                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
//                DispatchQueue.main.async {
//                    imageCache.cache[avatarURL] = data
//                    self.friendAvatarView.image = UIImage(data: data)
//                }
//            }
//        }
//    }
    
    public func setupCell(data: User){
        
        self.friendNameLabel?.text = data.firstLastName
//      self.setAndCacheLogo(data: data)
        photoService.photo(stringURL: data.avatar) {[weak self] (image) in
            DispatchQueue.main.async {
                self?.friendAvatarView.image = image
            }
        }
    }
    
    
    @objc func friendAvatarAnimate() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 50
        animation.mass = 1
        animation.duration = 0.45
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        self.friendAvatarView.layer.add(animation, forKey: nil)
    }
    
    func scrollAnimate() {
        let animationPhotoColletction = CABasicAnimation(keyPath: "opacity")
        animationPhotoColletction.fromValue = 0
        animationPhotoColletction.toValue = 1
        animationPhotoColletction.duration = 1
        animationPhotoColletction.beginTime = CACurrentMediaTime()
        animationPhotoColletction.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationPhotoColletction.fillMode = CAMediaTimingFillMode.backwards
        
        self.friendNameLabel.layer.add(animationPhotoColletction, forKey: nil)
        self.friendAvatarView.layer.add(animationPhotoColletction, forKey: nil)
    }
    
}
