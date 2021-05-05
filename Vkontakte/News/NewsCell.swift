//
//  NewsCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 03.03.2021.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet weak var logoView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var repostCountLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var repostButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    func setupConstraint(){
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor = self.bottomView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 0)
        let bottomAnchor = self.bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        let leftAnchor = self.bottomView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0)
        let rightAnchor = self.bottomView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0)
        NSLayoutConstraint.activate([topAnchor,bottomAnchor,leftAnchor,rightAnchor])
    }
}
