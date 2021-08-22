//
//  AvatarView.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 17.02.2021.
//

import UIKit

class AvatarView: UIView {
    
    @IBInspectable var shadowColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 2  {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 3, height: 2) {
        didSet {
            setNeedsDisplay()
        }
        
    }
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.frame = layer.bounds
        imageView.layer.borderColor = borderColor.cgColor
        imageView.layer.borderWidth = borderWidth
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        self.addSubview(imageView)
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = shadowOffset
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: imageView.frame.width / 2).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
}
