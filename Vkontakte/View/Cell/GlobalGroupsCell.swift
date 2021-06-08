//
//  GlobalGroupsCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 10.02.2021.
//

import UIKit

class GlobalGroupsCell: UITableViewCell {
    @IBOutlet var globalGroupsName: UILabel!
    @IBOutlet weak var logoView: AvatarView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let globalGroupViewGesture = UITapGestureRecognizer(target: self, action: #selector(groupLogoAnimate))
        logoView.addGestureRecognizer(globalGroupViewGesture)
        // Configure the view for the selected state
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
        
        self.logoView.layer.add(animation, forKey: nil)
    }
    
}
