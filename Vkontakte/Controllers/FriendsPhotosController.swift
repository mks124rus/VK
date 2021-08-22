//
//  FriendsPhotosController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 24.02.2021.
//

import UIKit
import RealmSwift
import SDWebImage
class FriendsPhotosController: UIViewController{
    
    @IBOutlet weak var friendsPhotosColletctionView: UICollectionView!
    @IBOutlet weak private var loadingView: UIView!
    @IBOutlet weak private var NoPhotoLabel: UILabel!{
        didSet{
            self.NoPhotoLabel.alpha = 0
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    private let previewPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .systemBackground
        imageView.alpha = 0
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    private var cellID = "FriendsPhotosViewCell"
    private var currentPhoto = Int()
    var userID: String = ""
    private var realmManager = RealmManager.shared
    private var networkManager = NetworkManager.shared
    private var photoService = PhotoService.instance
    private var userResults: Results<User>?{
        let usersResult: Results<User>? = realmManager?.getObjects()
        let ownerID = Int(userID)
        let user = usersResult?.filter("id = \(ownerID ?? 0) ")
        return user
    }
    private var photoResults: Results<Photo>? {
        let photoResult: Results<Photo>? = realmManager?.getObjects()
        let ownerID = Int(userID)
        let photo = photoResult?.filter("ownerID = \(ownerID ?? 0) ")
        return photo?.sorted(byKeyPath: "likeCount", ascending: false)
    }
    
    private var photoResultsNotificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendsPhotosColletctionView.alwaysBounceVertical = true
        self.friendsPhotosColletctionView.refreshControl? = refreshControl
        self.friendsPhotosColletctionView.addSubview(refreshControl)
        self.friendsPhotosColletctionView.delegate = self
        self.friendsPhotosColletctionView.dataSource = self
        
        self.view.addSubview(self.previewPhotoImageView)
        self.previewPhotoGesture()
        self.setPhotosNotification()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let photos = photoResults, photos.isEmpty {
            self.loadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        self.addRelationships()
    }
    
    deinit {
        self.photoResultsNotificationToken?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewPhotoImageView.frame = view.bounds
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        self.refreshControl.beginRefreshing()
        self.loadData() {[weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    fileprivate func setPhotosNotification() {
        photoResultsNotificationToken = photoResults?.observe { [weak self] change in
            switch change {
            case .initial(let photos):
                print("Initialize \(photos.count)")
                break
            case .update(let photos, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print("""
                        New count \(photos.count)
                        Deletions \(deletions)
                        Insertions \(insertions)
                        Modifications \(modifications)
                        """
                )
                
                let deletionsIndexPaths = deletions.map { IndexPath(item: $0, section: 0 )}
                let insertionsIndexPath = insertions.map {IndexPath(item: $0, section: 0 )}
                let modificationsIndexPath = modifications.map {IndexPath(item: $0, section: 0)}
                
                self?.friendsPhotosColletctionView.performBatchUpdates( {
                    self?.friendsPhotosColletctionView.deleteItems(at: deletionsIndexPaths)
                    self?.friendsPhotosColletctionView.insertItems(at: insertionsIndexPath)
                    self?.friendsPhotosColletctionView.reloadItems(at: modificationsIndexPath)
                }, completion: nil)
                
                break
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // default.realm создание связи между другом и его фотографиями
    private func addRelationships(){
        guard let photoResults = self.photoResults else {return}
        guard self.userResults != nil else {return}
        for photo in photoResults {
            let photoInRealm = userResults?.first?.photos.contains(photo)
            if photoInRealm == false{
                do{
                    self.userResults?.realm?.beginWrite()
                    self.userResults?.first?.photos.append(photo)
                    try self.userResults?.realm?.commitWrite()
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    private func loadData(completion: (() -> Void)? = nil){
        networkManager.loadFriendPhotos(userID: userID){
            [weak self] (result) in
            switch result {
            case .success(let photoArray):
                DispatchQueue.main.async {
                    try? self?.realmManager?.add(objects: photoArray)
                }
                self?.refreshControl.attributedTitle = NSAttributedString(string: "")
                self?.refreshControl.endRefreshing()
                completion?()
            case .failure(let error):
                print(error.localizedDescription)
                self?.refreshControl.attributedTitle = NSAttributedString(string: "Ошибка загрузки")
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func setupPreviewPhotoImageView(stringURL: String){
        photoService.photo(stringURL: stringURL) { [weak self] (image) in
            DispatchQueue.main.async {
                self?.previewPhotoImageView.image = image
                self?.previewPhotoIsOpenAnimation()
            }
        }
        //
        //        DispatchQueue.global().async {
        //            let data: Data = self.networkManager.getImageData(stringURL: stringURL)
        //            DispatchQueue.main.async {
        //                let pressedImage = UIImage(data: data)
        //                self.previewPhotoImageView.image = pressedImage
        //                self.previewPhotoIsOpenAnimation()
        //            }
        //        }
    }
}

extension FriendsPhotosController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.NoPhotoLabel.isHidden = true
        guard let photoResults = self.photoResults else {return}
        self.currentPhoto = indexPath.item
        let stringURL = photoResults[indexPath.item].url
        self.setupPreviewPhotoImageView(stringURL: stringURL)
    }
}

extension FriendsPhotosController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photoResults = self.photoResults else {return 0}
        if photoResults.isEmpty == true{
            //        if self.dataPhoto.isEmpty == true{
            self.noPhotoAnimation()
            self.loadingView.isHidden = true
            self.friendsPhotosColletctionView.isHidden = true
        } else {
            self.loadingView.isHidden = false
            self.loadingDotsAnimation()
            self.friendsPhotosColletctionView.isHidden = false
        }
        //        print(dataPhoto)
        return photoResults.count
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? FriendsPhotosCell else {return UICollectionViewCell()}
        //        let data = self.dataPhoto[indexPath.item]
        guard  let photoResults = self.photoResults else { return UICollectionViewCell()}
        let data = photoResults[indexPath.item]
        cell.setupCell(data: data, cell: cell, indexPath: indexPath)
        return cell
    }
}

extension FriendsPhotosController {
    
    //configure animation
    
    private func transformScaleAnimationPreviewPhoto(){
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 200
        animation.mass = 1.5
        animation.duration = 1
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        self.previewPhotoImageView.layer.add(animation, forKey: nil)
    }
    
    private func swipeLeftAnimationPreviewPhoto(){
        guard let photoResults = self.photoResults else {return}
        let currentStringURL = photoResults.map{$0.url}[self.currentPhoto]
        //        let dataImage: Data = self.networkManager.getImageData(stringURL: currentStringURL)
        //        let image = UIImage(data: dataImage)
        
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       usingSpringWithDamping: 5,
                       initialSpringVelocity: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transformScaleAnimationPreviewPhoto()
                       },
                       completion: {_ in
                        UIView.animate(withDuration: 0.3,
                                       animations: {
                                        self.previewPhotoImageView.center.x -= self.previewPhotoImageView.frame.width
                                       },
                                       completion: {_ in
                                        self.previewPhotoImageView.center.x += self.previewPhotoImageView.frame.width * 2
                                        UIView.animate(withDuration: 0.5,
                                                       delay: 0,
                                                       usingSpringWithDamping: 5,
                                                       initialSpringVelocity: 0,
                                                       options: .curveEaseOut,
                                                       animations: {
                                                        self.previewPhotoImageView.center.x -= self.previewPhotoImageView.frame.width
                                                        self.photoService.photo(stringURL: currentStringURL) {[weak self](image) in
                                                            DispatchQueue.main.async {
                                                                self?.previewPhotoImageView.image = image
                                                            }
                                                        }
                                                       },
                                                       completion: {_ in
                                                        
                                                       })
                                       })
                        
                        
                       })
        
    }
    private func swipeRightAnimationPreviewPhoto(){
        guard let photoResults = self.photoResults else {return}
        let currentStringURL = photoResults.map{$0.url}[self.currentPhoto]
        //        let dataImage: Data = self.networkManager.getImageData(stringURL: currentStringURL)
        //        let image = UIImage(data: dataImage)
        
        UIView.animate(withDuration: 0.75,
                       delay: 0,
                       usingSpringWithDamping: 5,
                       initialSpringVelocity: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transformScaleAnimationPreviewPhoto()
                       },
                       completion: {_ in
                        UIView.animate(withDuration: 0.3,
                                       animations: {
                                        self.previewPhotoImageView.center.x += self.previewPhotoImageView.frame.width
                                       },
                                       completion: {_ in
                                        self.previewPhotoImageView.center.x -= self.previewPhotoImageView.frame.width * 2
                                        UIView.animate(withDuration: 0.5,
                                                       delay: 0,
                                                       usingSpringWithDamping: 5,
                                                       initialSpringVelocity: 0,
                                                       options: .curveEaseOut,
                                                       animations: {
                                                        self.previewPhotoImageView.center.x += self.previewPhotoImageView.frame.width
                                                        self.photoService.photo(stringURL: currentStringURL) {[weak self](image) in
                                                            DispatchQueue.main.async {
                                                                self?.previewPhotoImageView.image = image
                                                            }
                                                        }
                                                       },
                                                       completion: {_ in
                                                        
                                                       })
                                       })
                        
                        
                       })
    }
    
    private func lastPhotoInPreviewPhotoAnimation(){
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 5,
                       initialSpringVelocity: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transformScaleAnimationPreviewPhoto()
                       },
                       completion: {_ in
                        UIView.animate(withDuration: 0.15,
                                       animations: {
                                        self.previewPhotoImageView.center.x -= self.previewPhotoImageView.frame.width/3
                                       },
                                       completion: {_ in
                                        UIView.animate(withDuration: 0.35,
                                                       delay: 0,
                                                       usingSpringWithDamping: 5,
                                                       initialSpringVelocity: 0,
                                                       options: .curveEaseOut,
                                                       animations: {
                                                        self.previewPhotoImageView.center.x += self.previewPhotoImageView.frame.width/3
                                                       },
                                                       completion: nil)
                                       })
                        
                        
                       })
    }
    
    private func firstPhotoInPreviewPhotoAnimation(){
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 5,
                       initialSpringVelocity: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.transformScaleAnimationPreviewPhoto()
                       },
                       completion: {_ in
                        UIView.animate(withDuration: 0.15,
                                       animations: {
                                        self.previewPhotoImageView.center.x += self.previewPhotoImageView.frame.width/3
                                       },
                                       completion: {_ in
                                        UIView.animate(withDuration: 0.35,
                                                       delay: 0,
                                                       usingSpringWithDamping: 5,
                                                       initialSpringVelocity: 0,
                                                       options: .curveEaseOut,
                                                       animations: {
                                                        self.previewPhotoImageView.center.x -= self.previewPhotoImageView.frame.width/3
                                                       },
                                                       completion: nil)
                                       })
                        
                        
                       })
    }
    
    private func previewPhotoIsCloseWithSwipeDownAnimation(){
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.previewPhotoImageView.center.y += 200
                        self.previewPhotoImageView.alpha = 0
                        
                       },
                       completion: {_ in
                        UIView.animate(withDuration: 0.25,
                                       delay: 0,
                                       options: .transitionCrossDissolve,
                                       animations: {
                                        self.previewPhotoImageView.center.y -= 200
                                        self.previewPhotoImageView.isHidden = true
                                        self.friendsPhotosColletctionView.alpha = 1
                                        self.navigationController?.navigationBar.alpha = 1
                                        self.tabBarController?.tabBar.alpha = 1
                                        
                                       },
                                       completion: {_ in
                                        self.navigationController?.navigationBar.isHidden = false
                                        self.tabBarController?.tabBar.isHidden = false
                                       })
                        
                       })
    }
    
    private func previewPhotoIsCloseWithSwipeUpAnimation(){
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.previewPhotoImageView.center.y -= 200
                        self.previewPhotoImageView.alpha = 0
                        
                       },
                       completion: {_ in
                        UIView.animate(withDuration: 0.25,
                                       delay: 0,
                                       options: .transitionCrossDissolve,
                                       animations: {
                                        self.previewPhotoImageView.center.y += 200
                                        self.previewPhotoImageView.isHidden = true
                                        self.friendsPhotosColletctionView.alpha = 1
                                        self.navigationController?.navigationBar.alpha = 1
                                        self.tabBarController?.tabBar.alpha = 1
                                        
                                       },
                                       completion: {_ in
                                        self.navigationController?.navigationBar.isHidden = false
                                        self.tabBarController?.tabBar.isHidden = false
                                       })
                        
                       })
    }
    
    private func previewPhotoIsOpenAnimation() {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.previewPhotoImageView.alpha = 1
                        self.previewPhotoImageView.isHidden = false
                        self.tabBarController?.tabBar.alpha = 0
                        self.navigationController?.navigationBar.alpha = 0
                       },
                       completion:{_ in
                        self.loadingView.isHidden = true
                        self.navigationController?.navigationBar.isHidden = true
                        self.tabBarController?.tabBar.isHidden = true
                        self.friendsPhotosColletctionView.alpha = 0
                       })
        
    }
    
    private func noPhotoAnimation() {
        UIView.animate(withDuration: 2.5,
                       animations: {
                        animate()
                       },
                       completion: {_ in
                        self.NoPhotoLabel.alpha = 1
                       })
        
        func animate(){
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.5
            animation.beginTime = CACurrentMediaTime() + 2
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.fillMode = CAMediaTimingFillMode.backwards
            self.NoPhotoLabel.layer.add(animation, forKey: nil)
        }
    }
    
    private func loadingDotsAnimation() {
        let layerDote = CAReplicatorLayer()
        layerDote.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        
        let dote = CALayer()
        dote.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        dote.cornerRadius = dote.frame.width / 2
        dote.backgroundColor = UIColor.darkGray.cgColor
        layerDote.addSublayer(dote)
        layerDote.instanceCount = 3
        layerDote.instanceTransform = CATransform3DMakeTranslation(25, 0, 0)
        
        let animationDote = CABasicAnimation(keyPath: "opacity")
        animationDote.fromValue = 0
        animationDote.toValue = 1
        animationDote.duration = 0.6
        animationDote.repeatCount = 10
        dote.add(animationDote, forKey: nil)
        layerDote.instanceDelay = animationDote.duration / Double(layerDote.instanceCount)
        self.loadingView.layer.addSublayer(layerDote)
        
        let animationLooadingView = CABasicAnimation(keyPath: "opacity")
        animationLooadingView.fromValue = 1
        animationLooadingView.toValue = 0
        animationLooadingView.duration = 0.5
        animationLooadingView.beginTime = CACurrentMediaTime() + 1
        animationLooadingView.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationLooadingView.fillMode = CAMediaTimingFillMode.backwards
        self.loadingView.layer.add(animationLooadingView, forKey: nil)
        
        let animationPhotoColletction = CABasicAnimation(keyPath: "opacity")
        animationPhotoColletction.fromValue = 0
        animationPhotoColletction.toValue = 1
        animationPhotoColletction.duration = 0.5
        animationPhotoColletction.beginTime = CACurrentMediaTime() + 1
        animationPhotoColletction.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animationPhotoColletction.fillMode = CAMediaTimingFillMode.backwards
        self.friendsPhotosColletctionView.layer.add(animationPhotoColletction, forKey: nil)
    }
}

extension FriendsPhotosController{
    
    //configure gesture
    
    private func previewPhotoGesture(){
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(respondToTapPreviewPhoto))
        //        previewPhotoImageView.addGestureRecognizer(tapGesture)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipePreviewPhoto))
        swipeRight.direction = .right
        previewPhotoImageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipePreviewPhoto))
        swipeRight.direction = .left
        previewPhotoImageView.addGestureRecognizer(swipeLeft)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipePreviewPhoto))
        swipeDown.direction = .down
        previewPhotoImageView.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipePreviewPhoto))
        swipeUp.direction = .up
        previewPhotoImageView.addGestureRecognizer(swipeUp)
    }
    
    @objc func respondToTapPreviewPhoto(){
        //hide or show navBar and tabBar on previewPhotoImageView
        var state : CGFloat = 0
        let stateNavBar = navigationController?.navigationBar.alpha
        if stateNavBar == state{
            state = 1
            self.navigationController?.navigationBar.isHidden = false
            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           options: .curveLinear,
                           animations: {
                            self.navigationController?.navigationBar.alpha = state
                           },
                           completion: nil)
            
        }else{
            state = 0
            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           options: .curveLinear,
                           animations: {
                            self.navigationController?.navigationBar.alpha = state
                           },
                           completion:{_ in
                            self.navigationController?.navigationBar.isHidden = true
                           })
        }
    }
    
    @objc func respondToSwipePreviewPhoto(gesture: UIGestureRecognizer){
        guard let photoResults = self.photoResults else {return}
        let stringURL = photoResults[self.currentPhoto].url
        
        self.photoService.photo(stringURL: stringURL) { [weak self] image in
            guard let self = self else {return}
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left:
                    print("swipe left")
                    if self.currentPhoto == photoResults.count - 1 {
                        print("end", +self.currentPhoto)
                        self.currentPhoto = photoResults.endIndex - 1
                        DispatchQueue.main.async {
                            self.previewPhotoImageView.image = image
                            self.lastPhotoInPreviewPhotoAnimation()
                        }

                    }else{
                        self.currentPhoto += 1
                        
                        DispatchQueue.main.async {
                            self.previewPhotoImageView.image = image
                            self.swipeLeftAnimationPreviewPhoto()

                        }
                        print("else left", +self.currentPhoto)
                    }
                    
                case UISwipeGestureRecognizer.Direction.right:
                    print("swipe right")
                    
                    if self.currentPhoto == photoResults.startIndex {
                        print("begin", +self.currentPhoto)
                        self.currentPhoto = photoResults.startIndex
                        DispatchQueue.main.async {
                            self.previewPhotoImageView.image = image
                            self.firstPhotoInPreviewPhotoAnimation()
                        }
                    }else{
                        self.currentPhoto -= 1
                        print("else right", +self.currentPhoto)
                        
                        DispatchQueue.main.async {
                            self.previewPhotoImageView.image = image
                            self.swipeRightAnimationPreviewPhoto()
                        }

                    }
                    
                case UISwipeGestureRecognizer.Direction.down:
                    print("swipe down")
                    self.previewPhotoIsCloseWithSwipeDownAnimation()
                case UISwipeGestureRecognizer.Direction.up:
                    print("swipe up")
                    self.previewPhotoIsCloseWithSwipeUpAnimation()
                default:
                    break
                }
            }
        }
    }
}
