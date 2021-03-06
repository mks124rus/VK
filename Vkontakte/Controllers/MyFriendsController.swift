//
//  MyFriendsController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 27.02.2021.
//

import UIKit
import RealmSwift
import Alamofire

struct Section {
    var letter : String
    var names : [User]
}

class MyFriendsController: UIViewController {
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .lightGray
//        refreshControl.attributedTitle = NSAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak private var myFriendsSearchBar: UISearchBar!
    
    @IBOutlet weak var myFriendsTableView: UITableView!{
        didSet{
            myFriendsTableView.sectionIndexBackgroundColor = .clear
            myFriendsTableView.dataSource = self
            myFriendsTableView.delegate = self
            myFriendsTableView.refreshControl = refreshControl
            myFriendsSearchBar.delegate = self
        }
    }
    
    private let myFriendsCellIdentifier = "MyFriendsCell"
    private let segueIdentifier = "showPhoto"
    private var dataUser: [Section] = []
    private var realmManager = RealmManager.shared
    private var networkManager = NetworkManager.shared
    private var filteredUsersNotificationToken: NotificationToken?
    private var operationQueue = OperationQueue()
    
    private var searchActive: Bool {
        if myFriendsSearchBar.text == "" || myFriendsSearchBar.text == nil{
            return false
        }
        return true
    }
    
    private var userResults: Results<User>? {
        let users: Results<User>? = realmManager?.getObjects()
        return users?.sorted(byKeyPath: "firstname", ascending: true)
    }
    private var dataUserFiltered: [Section] {
        if self.searchActive {
            let names = self.dataUser.map{$0.names}.flatMap{$0}
            let searchUsers = names.filter({(filter) -> Bool in
                return filter.firstLastName.range(of: self.myFriendsSearchBar.text ?? "", options: .caseInsensitive, range: nil, locale: nil) != nil
            })
            let groupedDictionary = Dictionary(grouping: searchUsers, by: {String($0.firstname.prefix(1))})
            let keys = groupedDictionary.keys.sorted()
            let filtered = keys.map{Section(letter: $0, names: groupedDictionary[$0] ?? [])}
            return filtered
        }
        return self.dataUser
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFilteredUserNotification()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let users = userResults, users.isEmpty{
//        self.loadData()
            self.loadDataWithOperations()
            self.createSection(userResults: users)
        }
//        self.createSection()
    }
    
    deinit {
        self.filteredUsersNotificationToken?.invalidate()
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        //        self.loadData()
        self.loadDataWithOperations() { [weak self] in
            self?.refreshControl.endRefreshing()
        }
        
    }
    
    fileprivate func loadDataWithOperations(completion: (() -> Void)? = nil){
        operationQueue.qualityOfService = .utility
        
        guard let request = networkManager.loadFriendsOperations() else {return}
//        загрузка данных
        let getDataOperation = GetDataOperation(request: request)
//        парсинг
        let parseData = ParseUserDataOperation()
//        сохранение в реалм
        let saveRealm = SaveToRealmUserOperation()
        
        parseData.addDependency(getDataOperation)
        saveRealm.addDependency(parseData)
       
        operationQueue.addOperation(getDataOperation)
        operationQueue.addOperation(parseData)
        OperationQueue.main.addOperation(saveRealm)
        
        completion?()
    }
    
    fileprivate func setFilteredUserNotification() {
        self.filteredUsersNotificationToken = self.userResults?.observe { [weak self] change in
            switch change {
            case .initial(let users):
                self?.createSection(userResults: users)
                self?.myFriendsTableView.reloadData()
                
                print("Initialize \(users.count)")
                break
            case .update(let users, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                self?.createSection(userResults: users)
                self?.myFriendsTableView.reloadData()
                
                let sections = self?.dataUser
                
                print("""
                        New count \(users.count)
                        Deletions \(deletions)
                        Insertions \(insertions)
                        Modifications \(modifications)
                        """
                )
                
                self?.myFriendsTableView.beginUpdates()

                if !modifications.isEmpty{
                
                    var modificationsIndexPath = [IndexPath]()
                    
                    for indexPath in modifications{
                        let usersName = users[indexPath].firstname
                        let sectionIndex = sections?.firstIndex(where: { (section) -> Bool in
                            return section.letter == usersName.prefix(1)
                        }) ?? 0
                        let usersID = users[indexPath].id
                        let rowIndex = sections?[sectionIndex].names.firstIndex(where: {(row) -> Bool in
                            return row.id == usersID
                        }) ?? 0

                        modificationsIndexPath.append(IndexPath(row: rowIndex, section: sectionIndex))
                    }
                    
                    self?.myFriendsTableView.reloadRows(at: modificationsIndexPath, with: .automatic)
                }
                self?.myFriendsTableView.endUpdates()
                break
            case .error(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    private func createSection(userResults: Results<User>){
        let groupedDictionary = Dictionary(grouping: userResults, by: {String($0.firstname.prefix(1))})
        let keys = groupedDictionary.keys.sorted()
        self.dataUser = keys.map{Section(letter: $0, names: groupedDictionary[$0] ?? [])}
    }
    
//    private func createSection(){
//        if let userResults = userResults{
//        let groupedDictionary = Dictionary(grouping: userResults, by: {String($0.firstname.prefix(1))})
//        let keys = groupedDictionary.keys.sorted()
//        self.dataUser = keys.map{Section(letter: $0, names: groupedDictionary[$0] ?? [])}
//        }
//        //        self.myFriendsTableView.reloadData()
//    }
    
    private func loadData(completion: (() -> Void)? = nil) {
        NetworkManager.shared.loadFriends() {
            [weak self] (result) in
            switch result {
            case .success(let usersArray):
                DispatchQueue.main.async {
                    try? self?.realmManager?.add(objects: usersArray)
                }
                self?.myFriendsTableView.reloadData()
                completion?()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? FriendsPhotosController else {return}
        guard let indexPath = self.myFriendsTableView.indexPathForSelectedRow else {return}
        let dataSource = self.dataUserFiltered[indexPath.section].names[indexPath.row]
        let userID = String(dataSource.id)
        destination.userID = userID
        
    }
    
    // DataSource without segue with Delegate (xib cell)
    
    //    func passData(){
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        guard let friendPhotosController = storyboard.instantiateViewController(identifier: "FriendsPhotosController") as? FriendsPhotosController else { return }
    //        guard let indexPath = myFriendsTableView.indexPathForSelectedRow else {return}
    //        let dataSource = dataUser[indexPath.section][indexPath.row]
    //        let userID = String(dataSource.id)
    //        friendPhotosController.userID = userID
    //        show(friendPhotosController, sender: nil)
    //    }
    
}

extension MyFriendsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.myFriendsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        self.view.endEditing(true)
        searchBar.text = nil
        self.myFriendsTableView.reloadData()

    }
}

extension MyFriendsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = self.dataUserFiltered[indexPath.section].names[indexPath.row]
            try? realmManager?.delete(object: user)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myFriendsTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MyFriendsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataUserFiltered.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataUserFiltered[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.myFriendsCellIdentifier, for: indexPath) as? MyFriendsCell else {return UITableViewCell()}
        let data = self.dataUserFiltered[indexPath.section].names[indexPath.row]
        cell.setupCell(data: data, cell: cell, indexPath: indexPath)
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.dataUserFiltered.map {$0.letter}
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: view.frame.size.width,
                                          height: 30))
        
        header.backgroundColor = myFriendsTableView.backgroundColor
        header.alpha = 1
        
        let titleForHeaderLabel = UILabel()
        titleForHeaderLabel.text = self.dataUserFiltered[section].letter
        titleForHeaderLabel.font = .boldSystemFont(ofSize: 15)
        titleForHeaderLabel.backgroundColor = myFriendsTableView.backgroundColor
        titleForHeaderLabel.textColor = .systemGray
        
        titleForHeaderLabel.frame = CGRect(
            x: 20,
            y: header.bounds.midY - titleForHeaderLabel.font.pointSize/2,
            width: header.frame.size.width,
            height: titleForHeaderLabel.font.pointSize)
        
        header.addSubview(titleForHeaderLabel)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    
}
