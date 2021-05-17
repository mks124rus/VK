//
//  MyFriendsViewController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 25.02.2021.
//

import UIKit

class MyFriendsViewController: UIViewController {


    @IBOutlet var customTableView: UITableView!
    @IBAction func logOut(unwindSegue: UIStoryboardSegue) {
        showLogOutAlert()
    }
    let tableViewCellIdentifire = "myFriendsCustomCell"
    let firstLettersHeaderView = "firstLetters"
    
    var sortedFirstLetters: [String] = []
    var sections = [myFriends]

    func passData() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let friendPhotosController = storyboard.instantiateViewController(identifier: "FriendsPhotosController") as? FriendsPhotosController else { return }
        guard let indexPath = customTableView.indexPathForSelectedRow else {return}
        let data = sections[indexPath.section][indexPath.row]
        friendPhotosController.friendPhoto = data.photo
        show(friendPhotosController, sender: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        customTableView.dataSource = self
        customTableView.delegate = self
        customTableView.register(UINib(nibName: "MyFriendsViewCell", bundle: nil), forCellReuseIdentifier: tableViewCellIdentifire)

        // TitleForHeaderSections: firstLetters from [struct]
        let firstLetters = myFriends.map {$0.titleFirstLetter}
        let uniqueFirstLetters = Array(Set(firstLetters))
        sortedFirstLetters = uniqueFirstLetters.sorted()
        sections = sortedFirstLetters.map { firstLetter in
        myFriends.filter { $0.titleFirstLetter == firstLetter }
        
        }
    }
    
    func showLogOutAlert() {
        let alert = UIAlertController(title: "Выйти?", message: nil, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Да", style: .destructive) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionYes)
        let actionNo = UIAlertAction(title: "Нет", style: .cancel, handler: nil)

        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//       guard segue.identifier == "showPhoto" else {return}
//       guard let destination = segue.destination as? FriendsPhotosController else {return}
//       guard let indexPath = customTableView.indexPathForSelectedRow else {return}
//       let dataSource = myFriends[indexPath.row]
//       destination.friendPhoto = dataSource.photo
//    }
    
}

extension MyFriendsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sortedFirstLetters
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection
//                                section: Int) -> String? {
//        return sortedFirstLetters[section]
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifire, for: indexPath) as? MyFriendsViewCell else {return UITableViewCell()}
        let data = sections[indexPath.section][indexPath.row]
        cell.friendNameLabel?.text = data.name
        cell.friendAvatarView?.image = UIImage(named: data.avatar.rawValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboard?.instantiateViewController(identifier: "FriendsPhotosController") as? FriendsPhotosController
//
//        let data = sections[indexPath.section][indexPath.row]
//        let vc = FriendsPhotosController(friendPhoto: data.photo)
//        navigationController?.pushViewController(vc, animated: true)
        passData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        header.backgroundColor = .systemBackground
        header.layer.borderWidth = 1
        header.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        header.alpha = 0.9
        
        let titleForHeaderLabel = UILabel(frame: CGRect(x: 16, y: 5, width: header.frame.size.width - 10 , height: header.frame.size.height - 10))
        titleForHeaderLabel.text = sortedFirstLetters[section]
        titleForHeaderLabel.font = .boldSystemFont(ofSize: 17)
        titleForHeaderLabel.textColor = .systemGray
        header.addSubview(titleForHeaderLabel)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 30
    }

    

    
    
}
