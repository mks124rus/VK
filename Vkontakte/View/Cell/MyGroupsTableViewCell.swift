//
//  MyGroupsTableViewCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 22.04.2021.
//

import UIKit

class MyGroupsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupsName: UILabel!
    @IBOutlet weak var myGroupsLogoView: AvatarView!
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
    
    private func setAndCacheLogo(data: Group){
        let imageCache = ImageCache.instance
        let stringURL = data.avatar
        if let data = imageCache.cache[stringURL]{
            self.myGroupsLogoView.image = UIImage(data: data)
        } else {
            DispatchQueue.global().async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: stringURL)
                DispatchQueue.main.async {
                    imageCache.cache[stringURL] = data
                    self.myGroupsLogoView.image = UIImage(data: data)
                }
            }
        }
    }
    
    func setupCell(data: Group, cell: MyGroupsTableViewCell, indexPath: IndexPath){
        self.myGroupsLogoView.image = nil
        cell.tag = indexPath.row
        if cell.tag == indexPath.row {
            self.setAndCacheLogo(data: data)
        }
        self.groupsName.text = data.name
    }
}
