//
//  NewsCellPhoto.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 10.05.2021.
//

import UIKit

class NewsCellPhoto: UITableViewCell {
    
    static let identifier = "NewsCellPhoto"
    
    @IBOutlet weak private var logoView: AvatarView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var textPostLabel: UILabel!
    @IBOutlet weak private var photoPost: UIImageView!
    @IBOutlet weak private var photoPostHeght: NSLayoutConstraint!
    @IBOutlet weak private var photoPostWidth: NSLayoutConstraint!
    @IBOutlet weak private var likeCountLabel: UILabel!
    
    @IBOutlet weak private var commentsCountLabel: UILabel!
    @IBOutlet weak private var repostCountLabel: UILabel!
    
    private var dateFormatter = NewsController.dateFormatter
    private var dataLogoCache: [IndexPath: Data] = [:]
    private var dataPostCache: [IndexPath: Data] = [:]
    
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
    
    private func setAndCacheLogo(data: News, indexPath: IndexPath){
        guard let avatarURL = data.avatar else {return}

        if let data = self.dataLogoCache[indexPath] {
            self.logoView.image = UIImage(data: data)
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
                DispatchQueue.main.async {
                    self.dataLogoCache[indexPath] = data
                    self.logoView.image = UIImage(data: data)
                }
            }
        }
    }
    
    private func setAndCachePhotoPost(data: News, indexPath: IndexPath){
        guard let photoPostURL = data.photoURL else {return}
        
        if let data = dataPostCache[indexPath] {
            self.photoPost.image = UIImage(data: data)
        } else {
            DispatchQueue.global().async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: photoPostURL)
                DispatchQueue.main.async {
                    self.dataPostCache[indexPath] = data
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
        self.textPostLabel.text = data.text
        self.photoPostHeght.constant = CGFloat(data.photoHeight ?? 0)
        
        self.setAndCacheLogo(data: data, indexPath: indexPath)
        self.setAndCachePhotoPost(data: data, indexPath: indexPath)
        
        self.likeCountLabel.text = String(data.likesCount)
        self.commentsCountLabel.text = String(data.commentsCount)
        self.repostCountLabel.text = String(data.repostsCount)
        
        
        let screenSize = UIScreen.main.bounds
        self.photoPostWidth.constant = screenSize.width
        let aspectRatio = self.photoPostWidth.constant / CGFloat(photoWidth)
        self.photoPostHeght.constant = CGFloat(photoHeiht) * aspectRatio


    }
}
