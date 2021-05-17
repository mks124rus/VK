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
    private var dataLogoCache: [IndexPath: Data] = [:]
    
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
    
    private func setAndCacheLogo(data: News, indexPath: IndexPath){
        guard let avatarURL = data.avatar else {return}

        if let data = self.dataLogoCache[indexPath] {
            self.logoView.image = UIImage(data: data)
        } else {
            DispatchQueue.global().async {
                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
                DispatchQueue.main.async {
                    self.dataLogoCache[indexPath] = data
                    self.logoView.image = UIImage(data: data)
                }
            }
        }
    }
    
    func setupCell(data: News, indexPath: IndexPath){

        let date = Date(timeIntervalSince1970: TimeInterval(data.date))
        self.dateLabel.text = self.dateFormatter.string(from: date)
        self.nameLabel.text = data.name
        self.textPostLabel.text = data.text
        self.setAndCacheLogo(data: data, indexPath: indexPath)
        self.likeCountLabel.text = String(data.likesCount)
        self.commentsCountLabel.text = String(data.commentsCount)
        self.repostCountLabel.text = String(data.repostsCount)
    }
}
