//
//  NewsController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 03.03.2021.
//

import UIKit
import Alamofire
class NewsController: UIViewController, ExpandPostTextLabel{

    @IBOutlet weak var newsTableView: UITableView! {
        didSet {
            newsTableView.rowHeight = UITableView.automaticDimension
            newsTableView.dataSource = self
            newsTableView.delegate = self
            newsTableView.register(UINib(nibName: NewsCellPhoto.identifier, bundle: nil), forCellReuseIdentifier: NewsCellPhoto.identifier)
            newsTableView.register(UINib(nibName: NewsCellText.identifier, bundle: nil), forCellReuseIdentifier: NewsCellText.identifier)
            newsTableView.refreshControl = refreshControl
            newsTableView.prefetchDataSource = self
        }
    }
    
    var nextFrom = ""
    var isLoading = false
    
    private var post:[News] = []
    private let viewModelFactory = NewsViewModelFactory()
    private var viewModels: [NewsViewModel] = []
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
        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
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
        NetworkManager.shared.loadNewsFeed(token: token, startFrom: nextFrom) {
            [weak self] (result, startFrom) in
            switch result {
            case .success(let newsArray):

                DispatchQueue.main.async {
                    self?.viewModels = self?.viewModelFactory.constructViewModels(from: newsArray) ?? []
                    self?.newsTableView.reloadData()
                    self?.refreshControl.attributedTitle = NSAttributedString(string: "")
                    completion?()
                }

                

//                    self?.post = newsArray




            case .failure(let error):
                print(error.localizedDescription)
                self?.refreshControl.attributedTitle = NSAttributedString(string: "Ошибка загрузки")
                self?.refreshControl.endRefreshing()
            }
        }
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
    
    func expandedText(button: UIButton, indexPath: IndexPath) {
        if let cell = newsTableView.cellForRow(at: indexPath) as? NewsCellPhoto{
            newsTableView.beginUpdates()
            cell.expandPostText()
            newsTableView.endUpdates()
        }
    }
    
}

extension NewsController: UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard let token = self.token else {
            return
        }
        
        // Выбираем максимальный номер секции, которую нужно будет отобразить в ближайшее время
        guard let maxSection = indexPaths.map({$0.section}).max() else {return}
        
        // Проверяем,является ли эта секция одной из трех ближайших к концу
        if maxSection > viewModels.count - 3,
           
           // Убеждаемся, что мы уже не в процессе загрузки данных
           !isLoading {
            // Начинаем загрузку данных и меняем флаг isLoading
            isLoading = true
            NetworkManager.shared.loadNewsFeed(token: token, startFrom: nextFrom) { [weak self] result, next  in
                guard let self = self else {return}
                switch result {
                case .success(let newsArray):
//                    self.post.append(contentsOf: newsArray)
                    self.viewModels.append(contentsOf: self.viewModelFactory.constructViewModels(from: newsArray))
                    self.nextFrom = next
                    self.newsTableView.reloadData()
                    self.isLoading = false
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}

extension NewsController: UITableViewDelegate {
    
}

extension NewsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
//        return self.post.count
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
        
//        let data = self.post[indexPath.section]
        let news = self.viewModels[indexPath.section]
        
        if news.photoPostURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellPhoto.identifier, for: indexPath) as? NewsCellPhoto else { return UITableViewCell()}
//            cell.setupCell(data: data, cell: cell, indexPath: indexPath)
            cell.configureCell(with: news, cell: cell, indexPath: indexPath)
            cell.configShowAllTextButton(indexPath: indexPath)
            cell.delegate = self
            cell.dateLabel.text = self.getDateCellText(for: indexPath, andTimestamp: news.date)
            return cell
            
        } else {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellText.identifier, for: indexPath) as? NewsCellText else { return UITableViewCell()}
            cell.dateLabel.text = self.getDateCellText(for: indexPath, andTimestamp: news.date)
            cell.configureCell(with: news, with: cell, with: indexPath)
//            cell.setupCell(data: data, cell: cell, indexPath: indexPath)
            return cell
        }
    }
}
