//
//  MyGroupsTableViewCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 22.04.2021.
//

import UIKit

class MyGroupsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupsName: UILabel!{
        didSet{
            groupsName.font = UIFont.systemFont(ofSize: 18)
            groupsName.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet weak var myGroupsLogoView: AvatarView!
    
    private let photoService = PhotoService.instance
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let groupLogoViewGesture = UITapGestureRecognizer(target: self, action: #selector(groupLogoAnimate))
        myGroupsLogoView.addGestureRecognizer(groupLogoViewGesture)
        
    }
    
    @objc func groupLogoAnimate() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 50
        animation.mass = 1
        animation.duration = 0.45
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        self.myGroupsLogoView.layer.add(animation, forKey: nil)
    }
    
//    private func setAndCacheLogo(data: Group){
//        let imageCache = ImageCache.instance
//        let stringURL = data.avatar
//        if let data = imageCache.cache[stringURL]{
//            self.myGroupsLogoView.image = UIImage(data: data)
//        } else {
//            DispatchQueue.global().async {
//                let data: Data = NetworkManager.shared.getImageData(stringURL: stringURL)
//                DispatchQueue.main.async {
//                    imageCache.cache[stringURL] = data
//                    self.myGroupsLogoView.image = UIImage(data: data)
//                }
//            }
//        }
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frameGroupsName()
        self.frameMyGroupsLogoView()
    }
    
    let insets: CGFloat = 20.0
    
    private func frameGroupsName(){
        let size = CGSize(width: bounds.width - self.insets * 3 - self.myGroupsLogoView.frame.width, height: bounds.height)
        let originX = bounds.minX + self.insets
        let originY = bounds.midY - size.height/2
        let origin = CGPoint(x: originX, y: originY)
        self.groupsName.frame = CGRect(origin: origin, size: size)
    }
    
    private func frameMyGroupsLogoView(){
        let avatarSideLenght: CGFloat = 45
        let size = CGSize(width: avatarSideLenght, height: avatarSideLenght)
        let origin = CGPoint(x: bounds.maxX - avatarSideLenght - insets, y: bounds.midY - avatarSideLenght/2)
        self.myGroupsLogoView.frame = CGRect(origin: origin, size: size)
    }
    
    public func setupCell(data: Group){
        self.myGroupsLogoView.image = nil
        self.groupsName.text = data.name
        //          self.setAndCacheLogo(data: data)
        photoService.photo(stringURL: data.avatar) {[weak self] image in
            DispatchQueue.main.async {
                self?.myGroupsLogoView.image = image
            }
        }
    }
}

