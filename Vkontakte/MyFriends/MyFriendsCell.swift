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
    private var dataAvatarCache: [IndexPath: Data] = [:]
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
    
    private func setAndCacheLogo(data: User, cell: MyFriendsCell, indexPath: IndexPath){
        let avatarURL = data.avatar
        self.friendAvatarView.image = nil // ставим нил чтобы не было мерцания аватарок при скроллинге
        cell.tag = indexPath.row //чтобы не путались аватарки друзей, после обновления таблицы, когда обновляется запись в рилм
        if let data = self.dataAvatarCache[indexPath] {
            self.friendAvatarView.image = UIImage(data: data)
        } else {
            DispatchQueue.global().async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
                DispatchQueue.main.async {
                    self.dataAvatarCache[indexPath] = data
                    if cell.tag == indexPath.row{
                    self.friendAvatarView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func setupCell(data: [Section], cell: MyFriendsCell, indexPath: IndexPath){
        let data = data[indexPath.section].names[indexPath.row]
        let name = data.firstLastName
        self.friendNameLabel?.text = name
        self.setAndCacheLogo(data: data, cell: cell, indexPath: indexPath)
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
