//
//  NewsController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 03.03.2021.
//

import UIKit
import Alamofire
class NewsController: UIViewController {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    private var post:[News] = []
    private var token = NetworkManager.shared.token
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        return dateFormatter
    }()
    
    private var dateTextCahce: [IndexPath: String] = [:]
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        //        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadData()
        self.newsTableView.dataSource = self
        self.newsTableView.delegate = self
        self.newsTableView.register(UINib(nibName: "NewsCellPhoto", bundle: nil), forCellReuseIdentifier: NewsCellPhoto.identifier)
        self.newsTableView.register(UINib(nibName: "NewsCellText", bundle: nil), forCellReuseIdentifier: NewsCellText.identifier)
        self.newsTableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        self.loadData() { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func loadData(completion: (() -> Void)? = nil) {
        guard let token = self.token else {
            return
        }
        NetworkManager.shared.loadNewsFeed(token: token) {
            [weak self] (result) in
            switch result {
            case .success(let newsArray):
                DispatchQueue.main.async {
                self?.post = newsArray
                self?.newsTableView.reloadData()
                completion?()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func showAllText(_ sender: UIButton){
        let ind = sender.tag
        print(ind)
        let indx = IndexPath(row: 0, section: ind)
        print(indx)
    }
    
    private func getDateCellText(for indexPath: IndexPath, andTimestamp timestamp: Int ) -> String {
        if let stringText = self.dateTextCahce[indexPath]{
            return stringText
        } else {
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let stringDate = self.dateFormatter.string(from: date)
            self.dateTextCahce[indexPath] = stringDate
            return stringDate
        }
    }
}

extension NewsController: UITableViewDelegate {
    
}

extension NewsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.post.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = self.post[indexPath.section]
        
        if data.photoURL != nil{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellPhoto.identifier, for: indexPath) as? NewsCellPhoto else { return UITableViewCell()}
            cell.setupCell(data: data)
            cell.dateLabel.text = self.getDateCellText(for: indexPath, andTimestamp: data.date)
            cell.showAllTextButton.addTarget(self, action: #selector(showAllText(_:)), for: .touchUpInside)
            return cell
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellText.identifier, for: indexPath) as? NewsCellText else { return UITableViewCell()}
            cell.dateLabel.text = self.getDateCellText(for: indexPath, andTimestamp: data.date)
            cell.setupCell(data: data)
            return cell
        }
    }
}
