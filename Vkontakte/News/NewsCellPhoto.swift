//
//  NewsCellPhoto.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 10.05.2021.
//

import UIKit
import RealmSwift

class NewsCellPhoto: UITableViewCell {
    
    static let identifier = "NewsCellPhoto"
    
    @IBOutlet weak private var logoView: AvatarView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak var textPostLabel: UILabel!
    @IBOutlet weak private var photoPost: UIImageView!
    @IBOutlet weak private var photoPostHeght: NSLayoutConstraint!
    @IBOutlet weak private var photoPostWidth: NSLayoutConstraint!
    @IBOutlet weak private var likeCountLabel: UILabel!
    
    @IBOutlet weak private var commentsCountLabel: UILabel!
    @IBOutlet weak private var repostCountLabel: UILabel!
    
    @IBOutlet weak var showAllTextButton: UIButton!
    private var dateFormatter = NewsController.dateFormatter
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.logoView.image = nil
        self.dateLabel.text = nil
        self.photoPost.image = nil
        self.textPostLabel.text = nil
        self.likeCountLabel.text = nil
        self.commentsCountLabel.text = nil
        self.repostCountLabel.text = nil
    }
    
    private func setAndCacheLogo(data: News){
        let imageCache = ImageCache.instance
        guard let avatarURL = data.avatar else {return}

        if let data = imageCache.cache[avatarURL] {
            self.logoView.image = UIImage(data: data)
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
                DispatchQueue.main.async {
                    imageCache.cache[avatarURL] = data
                    self.logoView.image = UIImage(data: data)
                }
            }
        }
    }
    
    private func setAndCachePhotoPost(data: News){
        let imageCache = ImageCache.instance
        guard let photoPostURL = data.photoURL else {return}
        
        if let data = imageCache.cache[photoPostURL] {
            self.photoPost.image = UIImage(data: data)
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: photoPostURL)
                DispatchQueue.main.async {
                    imageCache.cache[photoPostURL] = data
                    self.photoPost.image = UIImage(data: data)
                }
            }
        }
    }
    
    func setupCell(data: News, indexPath: IndexPath){

        guard let photoWidth = data.photoWidth else {return}
        guard let photoHeiht = data.photoHeight else {return}
        
        self.nameLabel.text = data.name
        let date = Date(timeIntervalSince1970: TimeInterval(data.date))
        self.dateLabel.text = self.dateFormatter.string(from: date)
        
        self.textPostLabel.text = data.text
        if textPostLabel.text!.count > 255 {
            textPostLabel.numberOfLines = 10
            showAllTextButton.isHidden = false
        } else {
            textPostLabel.numberOfLines = 0
            showAllTextButton.isHidden = true
        }
        self.photoPostHeght.constant = CGFloat(data.photoHeight ?? 0)
        self.setAndCacheLogo(data: data)
        self.setAndCachePhotoPost(data: data)
        
        self.likeCountLabel.text = String(data.likesCount)
        self.commentsCountLabel.text = String(data.commentsCount)
        self.repostCountLabel.text = String(data.repostsCount)
        
        
        let screenSize = UIScreen.main.bounds
        self.photoPostWidth.constant = screenSize.width
        let aspectRatio = self.photoPostWidth.constant / CGFloat(photoWidth)
        self.photoPostHeght.constant = CGFloat(photoHeiht) * aspectRatio


    }
    
    @IBAction func showAllPostText(_ sender: UIButton) {
    }
    
    
}
