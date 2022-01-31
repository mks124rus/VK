//
//  LikeControl.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 17.02.2021.
//

import UIKit

class LikeControl: UIControl{
    
    var likeCount = 0
    var userLikeCount = 0
    private var isLiked = false
    
    var labelLikeCount: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemBlue
        return label
    }()
    
    var heartButtonOnBar: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(systemName: "heart")
        button.setImage(buttonImage, for: .normal)
        button.tintColor = UIColor.systemBlue
        return button
    }()
    
    private var likeHeartCenter: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = UIColor.white
        imageView.clipsToBounds = true
        
        imageView.alpha = 0
        
        imageView.layer.masksToBounds = false
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset =  CGSize(width: 0, height: 0)
        return imageView
    }()
    
    private var barBottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.alpha = 1
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    lazy private var tapAddLikeGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(addOrUndoLikeOnTap))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        
        
        return recognizer
    }()
    
    public func addUndoLike(){
        if likeCount == userLikeCount {
            isLiked = true
            self.likeControl()
        } else {
            isLiked = false
            self.likeControl()
        }
    }
    
    @objc func addOrUndoLikeOnTap() {
        addUndoLike()
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.heartButtonOnBar.addGestureRecognizer(tapAddLikeGesture)
//        self.setupView()
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.heartButtonOnBar.addGestureRecognizer(tapAddLikeGesture)
        labelLikeCount.text = String(likeCount)
        
        self.addSubview(barBottomView)
        self.addSubview(likeHeartCenter)
        barBottomView.addSubview(labelLikeCount)
        barBottomView.addSubview(heartButtonOnBar)
        
//        self.setupFrameView()
    }
    
    private func heartLikeButtonOnBarAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.7
        animation.toValue = 1
        animation.stiffness = 150
        animation.mass = 1
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        //        self.labelLikeCount.layer.add(animation, forKey: nil)
        self.heartButtonOnBar.layer.add(animation, forKey: nil)
    }
    
    private func likeHeartCenterAnimation() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: .beginFromCurrentState,
                       animations: {
            self.likeHeartCenter.alpha = 0.9
        },
                       completion: {_ in
            self.likeHeartCenter.alpha = 0
        })
    }
    


    private func likeControl(){
        if isLiked {
            likeCount += 1
            labelLikeCount.textColor = .systemRed
            labelLikeCount.text = String(likeCount)
            let buttonImage = UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
            heartButtonOnBar.setImage(buttonImage, for: .normal)
            self.heartLikeButtonOnBarAnimation()
            self.likeHeartCenterAnimation()
        } else {
            likeCount = userLikeCount
            labelLikeCount.textColor = .systemBlue
            labelLikeCount.text = String(likeCount)
            let buttonImage = UIImage(systemName: "heart")
            heartButtonOnBar.setImage(buttonImage, for: .normal)
        }

    }
    
    public func setupFrameView(middleY midY: CGFloat) {
        barBottomView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        let insets: CGFloat = 2
        let labelSize = CGSize(width: 60, height: 14)
        let buttonSize = CGSize(width: 16, height: 14)
        let heartImageSize = CGSize(width: 42, height: 37.5)
        
        let labelOrigin = CGPoint(x: barBottomView.bounds.maxX - labelSize.width - buttonSize.width - insets,
                                  y: barBottomView.bounds.midY - labelSize.height/2)
        
        let buttonOrigin = CGPoint(x: barBottomView.bounds.maxX - buttonSize.width - insets,
                                   y: barBottomView.bounds.midY - buttonSize.height/2)
        
        let heartImageOrigin = CGPoint(x: self.bounds.midX - heartImageSize.width/2,
                                       y: -midY - bounds.height + heartImageSize.height/2)
        
        labelLikeCount.frame = CGRect(origin: labelOrigin, size: labelSize)
        heartButtonOnBar.frame = CGRect(origin: buttonOrigin, size: buttonSize)
        likeHeartCenter.frame = CGRect(origin: heartImageOrigin, size: heartImageSize)

    }
    
    
}
