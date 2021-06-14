//
//  NewsCellText.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 15.05.2021.
//

import UIKit

class NewsCellText: UITableViewCell {

    @IBOutlet weak var logoView: AvatarView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    

    @IBOutlet weak private var textPostLabel: UILabel!
    
    
    @IBOutlet weak private var likeButton: UIButton!
    @IBOutlet weak private var likeCountLabel: UILabel!
    
    @IBOutlet weak private var commentsButton: UIButton!
    @IBOutlet weak private var commentsCountLabel: UILabel!
    
    @IBOutlet weak private var repostButton: UIButton!
    @IBOutlet weak private var repostCountLabel: UILabel!
    
    static let identifier = "NewsCellText"
    
    private var dateFormatter = NewsController.dateFormatter
    private var photoService = PhotoService.instance
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
        self.likeCountLabel.text = nil
        self.commentsCountLabel.text = nil
        self.repostCountLabel.text = nil
    }
    
//    private func setAndCacheLogo(data: News){
//        let imageCache = ImageCache.instance
//        guard let avatarURL = data.avatar else {return}
//
//        if let data = imageCache.cache[avatarURL] {
//            self.logoView.image = UIImage(data: data)
//        } else {
//            DispatchQueue.global().async {
//                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
//                DispatchQueue.main.async {
//                    imageCache.cache[avatarURL] = data
//                    self.logoView.image = UIImage(data: data)
//                }
//            }
//        }
//    }
    
    public func setupCell(data: News){
        guard let stringURL = data.avatar else {return}
        let date = Date(timeIntervalSince1970: TimeInterval(data.date))
        self.dateLabel.text = self.dateFormatter.string(from: date)
        self.nameLabel.text = data.name
        self.textPostLabel.text = data.text
//        self.setAndCacheLogo(data: data)
        photoService.photo(stringURL: stringURL) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.logoView.image = image
            }
        }
        self.likeCountLabel.text = String(data.likesCount)
        self.commentsCountLabel.text = String(data.commentsCount)
        self.repostCountLabel.text = String(data.repostsCount)
    }
}
