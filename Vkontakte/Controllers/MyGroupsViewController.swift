//
//  MyGroupsViewController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 22.04.2021.
//

import UIKit
import RealmSwift
class MyGroupsViewController: UIViewController {
    
    @IBOutlet weak var myGroupsTableView: UITableView!{
        didSet{
            self.myGroupsTableView.dataSource = self
            self.myGroupsTableView.refreshControl = refreshControl
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 12)])
            refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    let cellID = "MyGroupsCell"
    
    private var realmManager = RealmManager.shared
    private var networkManager = NetworkManager.shared
    private let adapter = NetworkManagerAdapter()
    
    private var groupResults: Results<Group>? {
        let results: Results<Group>? = realmManager?.getObjects()
        return results?.sorted(byKeyPath: "name", ascending: true)
    }
    private var groupsAdapter: [GroupAdapter]?
    
    private var groupsNotificationToken: NotificationToken?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.loadData()
//        self.loadDataPromise()
//        self.setGroupsNotification()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adapter.getMyGroups { [weak self] groups in
            self?.groupsAdapter = groups.sorted {$0.name < $1.name}
            self?.myGroupsTableView.reloadData()
        }
    }
    
    deinit {
//        self.groupsNotificationToken?.invalidate()
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
//        self.loadDataPromise()
        adapter.getMyGroups { [weak self] groups in
            self?.groupsAdapter = groups.sorted {$0.name < $1.name}
            self?.myGroupsTableView.reloadData()
        }
        self.myGroupsTableView.refreshControl?.endRefreshing()
//        DispatchQueue.main.async {
//            self.loadData() { [weak self] in
//                self?.myGroupsTableView.refreshControl?.endRefreshing()
//            }
//        }
    }
    
    private func loadData(completion: (() -> Void)? = nil){
        NetworkManager.shared.loadGroups() {
            [weak self] (result) in
            
            switch result {
            case .success(let groupsArray):
                    try? self?.realmManager?.add(objects: groupsArray)
                    completion?()
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func loadDataPromise(completion: (() -> Void)? = nil){
        self.networkManager.loadGroupsPromise()
            .done {[weak self] (groups) in
                try self?.realmManager?.add(objects: groups)
                completion?()
            }
            .catch { (error) in
                print(error.localizedDescription)
            }
    }
    
    fileprivate func setGroupsNotification() {
        groupsNotificationToken = groupResults?.observe { [weak self] change in
            switch change {
            case .initial(let groups):
                print("Initialize \(groups.count)")
                break
            case .update(let groups, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print("""
                        New count \(groups.count)
                        Deletions \(deletions)
                        Insertions \(insertions)
                        Modifications \(modifications)
                        """
                )
                
                self?.myGroupsTableView.beginUpdates()
                let deletionsIndexPaths = deletions.map { IndexPath(item: $0, section: 0 )}
                let insertionsIndexPath = insertions.map {IndexPath(item: $0, section: 0 )}
                let modificationsIndexPath = modifications.map {IndexPath(item: $0, section: 0)}
                
                self?.myGroupsTableView.deleteRows(at: deletionsIndexPaths, with: .automatic)
                self?.myGroupsTableView.insertRows(at: insertionsIndexPath, with: .automatic)
                self?.myGroupsTableView.reloadRows(at: modificationsIndexPath, with: .automatic)
                self?.myGroupsTableView.endUpdates()
                
                break
            case .error(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

extension MyGroupsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.groupResults?.count ?? 0
        return self.groupsAdapter?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? MyGroupsTableViewCell else {return UITableViewCell()}
//        guard let data = groupResults?[indexPath.row] else {return UITableViewCell()}
        guard let data = groupsAdapter?[indexPath.row] else {return UITableViewCell()}
            cell.setupCell(data: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            guard let myGroup = groupResults?[indexPath.row] else {
//                return
//
//            }
//            try? realmManager?.delete(object: myGroup)
        }
    }
}

