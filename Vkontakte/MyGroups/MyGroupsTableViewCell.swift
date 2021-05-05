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

}
