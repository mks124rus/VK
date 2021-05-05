//
//  NewsController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 03.03.2021.
//

import UIKit

class NewsController: UIViewController {
    @IBOutlet weak private var newsTableView: UITableView!
    private let cellIdentifier = "newsCell"
    private var data:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newsTableView.dataSource = self
        self.newsTableView.delegate = self
        self.newsTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
}

extension NewsController: UITableViewDelegate {
    
}

extension NewsController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsCell else {return UITableViewCell()}
        
        let data = myGroups[indexPath.row]
        cell.nameLabel.text = data.name
        cell.logoView.image = UIImage(named: data.logo.rawValue)
        cell.postImageView.image = UIImage(named: data.postPhoto)
        cell.discriptionLabel.text = data.postText
        
        if cell.postImageView.image == UIImage(named: "") {
            cell.setupConstraint()
        }
        
        cell.dateLabel.text = "час назад"
        
        
        return cell
    }
    
    
}
