//
//  NewsCellPhoto.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 10.05.2021.
//

import UIKit
import RealmSwift

protocol ExpandPostTextLabel: AnyObject{
    func expandedText(button: UIButton, indexPath: IndexPath)
}

class NewsCellPhoto: UITableViewCell {
    
    weak var delegate: ExpandPostTextLabel?
    static let identifier = "NewsCellPhoto"
    
    @IBOutlet weak private var logoView: AvatarView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textPostLabel: UILabel!
    @IBOutlet weak private var photoPost: UIImageView!
    @IBOutlet weak private var photoPostHeght: NSLayoutConstraint!
    @IBOutlet weak private var photoPostWidth: NSLayoutConstraint!
    @IBOutlet weak private var likeCountLabel: UILabel!
    
    @IBOutlet weak private var commentsCountLabel: UILabel!
    @IBOutlet weak private var repostCountLabel: UILabel!
    
    @IBOutlet weak var showAllTextButton: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomView: UIView!
    
    var isExpanded = Bool()
    var indexPath = IndexPath()
    
    private let photoService = PhotoService.instance
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
    
//    private func setAndCacheLogo(data: News){
//        let imageCache = ImageCache.instance
//        guard let avatarURL = data.avatar else {return}
//
//        if let data = imageCache.cache[avatarURL] {
//            self.logoView.image = UIImage(data: data)
//        } else {
//            DispatchQueue.global(qos: .userInteractive).async {
//                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
//                DispatchQueue.main.async {
//                    imageCache.cache[avatarURL] = data
//                    self.logoView.image = UIImage(data: data)
//                }
//            }
//        }
//    }
    
//    private func setAndCachePhotoPost(data: News){
//        let imageCache = ImageCache.instance
//        guard let photoPostURL = data.photoURL else {return}
//
//        if let data = imageCache.cache[photoPostURL] {
//            self.photoPost.image = UIImage(data: data)
//        } else {
//            DispatchQueue.global(qos: .userInteractive).async {
//                let data: Data = NetworkManager.shared.getImageData(stringURL: photoPostURL)
//                DispatchQueue.main.async {
//                    imageCache.cache[photoPostURL] = data
//                    self.photoPost.image = UIImage(data: data)
//                }
//            }
//        }
//    }
    
    public func configureCell(with viewModel: NewsViewModel, cell: NewsCellPhoto, indexPath: IndexPath) {
        
        self.nameLabel.text = viewModel.name
        self.textPostLabel.text = viewModel.text
        
        guard let photoWidth = viewModel.photoWidth,
              let photoHeight = viewModel.photoHeight else {return}
        
        self.photoPostHeght.constant = CGFloat(viewModel.photoHeight ?? 0)
        
        let screenSize = UIScreen.main.bounds
        self.photoPostWidth.constant = screenSize.width
        let aspectRatio = self.photoPostWidth.constant / CGFloat(photoWidth)
        self.photoPostHeght.constant = CGFloat(photoHeight) * aspectRatio
        
        cell.tag = indexPath.row
        
        if cell.tag == indexPath.row {
            if let url = viewModel.avatarURL{
                photoService.photo(stringURL:url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.logoView.image = image
                    }
                }
            }

            if let url = viewModel.photoPostURL{
                photoService.photo(stringURL:url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.photoPost.image = image
                    }
                }
            }
        }

        self.likeCountLabel.text = viewModel.likesCount
        self.commentsCountLabel.text = viewModel.commentsCount
        self.repostCountLabel.text = viewModel.repostsCount
        
        
    }
    
    public func setupCell(data: News, cell: NewsCellPhoto, indexPath: IndexPath){
        cell.tag = indexPath.row
        
        guard let photoWidth = data.photoWidth,
              let photoHeiht = data.photoHeight,
              let logoURL = data.avatar,
              let photoURL = data.photoURL else { return }

        self.nameLabel.text = data.name
        self.textPostLabel.text = data.text
        
        self.photoPostHeght.constant = CGFloat(data.photoHeight ?? 0)
        
        if cell.tag == indexPath.row {
            photoService.photo(stringURL: logoURL) { [weak self](image) in
                DispatchQueue.main.async {
                    self?.logoView.image = image
                }
            }
            photoService.photo(stringURL: photoURL) { [weak self](image) in
                DispatchQueue.main.async {
                    self?.photoPost.image = image
                }
            }
        }


        self.likeCountLabel.text = String(data.likesCount)
        self.commentsCountLabel.text = String(data.commentsCount)
        self.repostCountLabel.text = String(data.repostsCount)
        
        
        let screenSize = UIScreen.main.bounds
        self.photoPostWidth.constant = screenSize.width
        let aspectRatio = self.photoPostWidth.constant / CGFloat(photoWidth)
        self.photoPostHeght.constant = CGFloat(photoHeiht) * aspectRatio


    }
    
    public func expandPostText(){
        guard let text = textPostLabel.text else {return}
        print(text.count)
        
        if isExpanded == false {
            textPostLabel.numberOfLines = 0
            showAllTextButton.setTitle("Скрыть", for: .normal)
            isExpanded = true
        } else {
            textPostLabel.numberOfLines = 10
            showAllTextButton.setTitle("Показать полностью...", for: .normal)
            isExpanded = false
        }
    }
    
    public func configShowAllTextButton(indexPath: IndexPath){
        showAllTextButton.tag = indexPath.row
        self.indexPath = indexPath
        
        guard let text = textPostLabel.text else {return}

        if text.count > 250 {
            if text.count == 255 {
                showAllTextButton.isHidden = true
            } else {
                showAllTextButton.isHidden = false
                showAllTextButton.setTitle("Показать полностью...", for: .normal)
                textPostLabel.numberOfLines = 10
                isExpanded = false
            }
        } else {
            showAllTextButton.isHidden = true
        }
    }
    
    @IBAction func showAllPostText(_ sender: UIButton) {
        delegate?.expandedText(button: sender, indexPath: indexPath)
        print("tap")
    }
    
}


