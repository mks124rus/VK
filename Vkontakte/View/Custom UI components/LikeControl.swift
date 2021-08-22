//
//  LikeControl.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 17.02.2021.
//

import UIKit

class LikeControl: UIControl{
    
    var labelLikeCount = UILabel()
    var heartButtonOnBar = UIButton()
    private var likeHeartCenter = UIImageView()
    private var barBottomView = UIView()
    var likeCount = 0
    var userLikeCount = 0
    
    
    lazy private var tapAddLikeGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(addOrUndoLikeOnTap))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        
        
        return recognizer
    }()
    
    @objc func addOrUndoLikeOnTap() {
        if likeCount == userLikeCount {
            self.addLike()
        } else {
            self.undoLike()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.heartButtonOnBar.addGestureRecognizer(tapAddLikeGesture)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.heartButtonOnBar.addGestureRecognizer(tapAddLikeGesture)
        self.setupView()
    }
    
    func heartLikeButtonOnBarAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.7
        animation.toValue = 1
        animation.stiffness = 150
        animation.mass = 1
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        self.labelLikeCount.layer.add(animation, forKey: nil)
        self.heartButtonOnBar.layer.add(animation, forKey: nil)
    }
    
    func likeHeartCenterAnimation() {
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
    
    func addLike(){
        likeCount += 1
        labelLikeCount.textColor = .systemRed
        labelLikeCount.text = String(likeCount)
        let buttonImage = UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        heartButtonOnBar.setImage(buttonImage, for: .normal)
        self.heartLikeButtonOnBarAnimation()
        self.likeHeartCenterAnimation()
    }
    
    func undoLike(){
        likeCount = userLikeCount
        labelLikeCount.textColor = .systemBlue
        labelLikeCount.text = String(likeCount)
        let buttonImage = UIImage(systemName: "heart")
        heartButtonOnBar.setImage(buttonImage, for: .normal)
    }
    
    
    func setupView() {
        barBottomView.backgroundColor = .systemBackground
        barBottomView.alpha = 0.9
        barBottomView.isUserInteractionEnabled = true
        self.addSubview(barBottomView)
        
        labelLikeCount.textAlignment = .right
        labelLikeCount.font = .systemFont(ofSize: 14)
        labelLikeCount.textColor = .systemBlue
        labelLikeCount.text = String(likeCount)
        barBottomView.addSubview(labelLikeCount)
        
        let buttonImage = UIImage(systemName: "heart")
        heartButtonOnBar.setImage(buttonImage, for: .normal)
        heartButtonOnBar.tintColor = UIColor.systemBlue
        barBottomView.addSubview(heartButtonOnBar)
        
        likeHeartCenter.image = UIImage(systemName: "heart.fill")
        likeHeartCenter.tintColor = UIColor.white
        likeHeartCenter.clipsToBounds = true
        likeHeartCenter.layer.bounds = self.bounds
        likeHeartCenter.alpha = 0
        
        likeHeartCenter.layer.masksToBounds = false
        likeHeartCenter.layer.shadowColor = UIColor.black.cgColor
        likeHeartCenter.layer.shadowRadius = 4
        likeHeartCenter.layer.shadowOpacity = 0.5
        likeHeartCenter.layer.shadowOffset =  CGSize(width: 0, height: 0)
        self.addSubview(likeHeartCenter)
        
        barBottomView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let heightLabelLikeCount: CGFloat = 16
        let heightHeartButtonBar: CGFloat = 14
        labelLikeCount.frame = CGRect(x: self.bounds.maxX - 76, y: self.bounds.midY - heightLabelLikeCount/2, width: 60, height: heightLabelLikeCount)
        heartButtonOnBar.frame = CGRect(x: self.bounds.maxX - 16, y: self.bounds.midY - heightHeartButtonBar/2, width: heightHeartButtonBar + 2, height: heightHeartButtonBar)
        likeHeartCenter.frame = CGRect(x: 44, y: -65, width: 42, height: 37.5)
    }
    
    
}
