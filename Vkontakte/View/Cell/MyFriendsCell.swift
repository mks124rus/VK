//
//  MyFriendsCell.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 27.02.2021.
//

import UIKit

class MyFriendsCell: UITableViewCell {
    @IBOutlet weak private var friendNameLabel: UILabel!
    @IBOutlet weak private var friendAvatarView: AvatarView!
    @IBOutlet weak var contView: UIView!
    
    private let photoService = PhotoService.instance
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.friendNameLabel.text = nil
        self.friendAvatarView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let friendAvatarViewGesture = UITapGestureRecognizer(target: self, action: #selector(friendAvatarAnimate))
        self.friendAvatarView.addGestureRecognizer(friendAvatarViewGesture)
        
    }
    
//    private func setAndCacheLogo(data: User){
//        let imageCache = ImageCache.instance
//        let avatarURL = data.avatar
//
//        if let data = imageCache.cache[avatarURL] {
//            self.friendAvatarView.image = UIImage(data: data)
//        } else {
//            DispatchQueue.global(qos: .userInteractive).async {
//                let data: Data = NetworkManager.shared.getImageData(stringURL: avatarURL)
//                DispatchQueue.main.async {
//                    imageCache.cache[avatarURL] = data
//                    self.friendAvatarView.image = UIImage(data: data)
//                }
//            }
//        }
//    }
    
    let insets: CGFloat = 20.0
    
    func setTextFriendNameLabel(text: String){
        self.friendNameLabel.text = text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frameFriendAvatarView()
        self.frameFriendNameLabel()
    }
    
    private func getFriendNameLabelSize(text: String, font: UIFont) -> CGSize{
        
        // определяем максимальную ширину текста - это ширина ячейки минус отступы слева и справа и минус аватарка
        let maxWidth = bounds.width - insets * 2 - self.friendAvatarView.frame.width
        //получаем размеры блока, в который надо вписать надпись
        //используем максимальную ширину и максимально возможную высоту
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        //получим прямоугольник, который займёт наш текст в этом блоке
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        //получаем ширину блока, переводим ее в Double
        let width = Double(rect.size.width)
        //получаем высоту блока, переводим ее в Double
        let height = Double(rect.size.height)
        //получаем размер, при этом округляем значения до большего целого числа
        let size = CGSize(width: ceil(width), height: ceil(height))

        return size
    }
    
    private func frameFriendNameLabel(){
        //получаем размер текста, передавая сам текст и шрифт.
        let size = getFriendNameLabelSize(text: friendNameLabel.text ?? "Имя Фамилия", font: friendNameLabel.font)
        let originX = bounds.minX + insets
        let originY = bounds.midY - size.height/2
        let origin = CGPoint(x: originX, y: originY)
        self.friendNameLabel.frame = CGRect(origin: origin, size: size)
    }
    
    private func frameFriendAvatarView(){
        let avatarSideLenght: CGFloat = 40
        let size = CGSize(width: avatarSideLenght, height: avatarSideLenght)
        let origin = CGPoint(x: bounds.maxX - avatarSideLenght - insets*1.5, y: bounds.midY - avatarSideLenght/2)
        self.friendAvatarView.frame = CGRect(origin: origin, size: size)
    }
    
    
    
    public func setupCell(data: User, cell: MyFriendsCell, indexPath: IndexPath){
        cell.tag = indexPath.row
        if cell.tag == indexPath.row {
            self.setTextFriendNameLabel(text: data.firstLastName)
            photoService.photo(stringURL: data.avatar) {[weak self] (image) in
                DispatchQueue.main.async {
                    self?.friendAvatarView.image = image
                }
            }
        }
        
//      self.friendNameLabel?.text = data.firstLastName
//      self.setAndCacheLogo(data: data)

    }
    
    
    @objc func friendAvatarAnimate() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 50
        animation.mass = 1
        animation.duration = 0.45
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        self.friendAvatarView.layer.add(animation, forKey: nil)
    }
    
    func scrollAnimate() {
        let animationPhotoColletction = CABasicAnimation(keyPath: "opacity")
        animationPhotoColletction.fromValue = 0
        animationPhotoColletction.toValue = 1
        animationPhotoColletction.duration = 1
        animationPhotoColletction.beginTime = CACurrentMediaTime()
        animationPhotoColletction.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationPhotoColletction.fillMode = CAMediaTimingFillMode.backwards
        
        self.friendNameLabel.layer.add(animationPhotoColletction, forKey: nil)
        self.friendAvatarView.layer.add(animationPhotoColletction, forKey: nil)
    }
    
}
