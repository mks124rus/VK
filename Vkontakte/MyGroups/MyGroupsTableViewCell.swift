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
    private var dataLogoCache: [IndexPath : Data] = [:]
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
    
    private func setAndCacheLogo(data: Group, indexPath: IndexPath){
        let stringURL = data.avatar
        if let data = self.dataLogoCache[indexPath] {
            self.myGroupsLogoView.image = UIImage(data: data)
        } else {
            DispatchQueue.global().async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: stringURL)
                DispatchQueue.main.async {
                    self.dataLogoCache[indexPath] = data
                    self.myGroupsLogoView.image = UIImage(data: data)
                }
            }
        }
    }
    
    func setupCell(data: Group, indexPath: IndexPath){
        self.setAndCacheLogo(data: data, indexPath: indexPath)
        self.groupsName.text = data.name
    }

}
