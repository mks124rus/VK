//
//  PreferenceViewController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 19.03.2021.
//

import UIKit

class PreferenceViewController: UITableViewController {
    
    @IBOutlet weak var clearCacheLabel: UILabel!{
        didSet{
            clearCacheLabel.text = "Очистить кеш"
        }
    }
    @IBOutlet weak var cacheSizeLabel: UILabel! {
        didSet {
            cacheSizeLabel.text = "0 KB"
        }
    }
    @IBOutlet weak var exitLabel: UILabel!{
        didSet {
            exitLabel.text = "Выход"
        }
    }
    private let photoService = PhotoService.instance
    private let realmMngr = RealmManager.shared

    private func showLogOutAlert() {
        let alert = UIAlertController(title: "Выйти?", message: nil, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Да", style: .destructive) { action in
            self.dismiss(animated: true, completion: nil)
        }
        
        let actionNo = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    ///Delete directory "Images" in /Library/Caches/ and erases all entries in Documents/default.realm
    private func cleanCacheAndRealmData(){
        let alert = UIAlertController(title: nil, message: "Будет очищена база реалм и кеш изображений", preferredStyle: .actionSheet)
        let actionClear = UIAlertAction(title: "Очистить", style: .default) { _ in
            try? self.realmMngr?.deleteAll()
            self.photoService.clearCache()
            self.setCacheSizeLabelText()
        }
        
        let actionCancel = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        alert.addAction(actionClear)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    private func setCacheSizeLabelText() {
        guard let imageCacheDir = PhotoService.instance.imageCacheURL else {return}
        do {
            if var sizeOnDisk = try imageCacheDir.sizeOnDisk() {
                if sizeOnDisk == "Zero KB" {
                    sizeOnDisk = "0 KB"
                }
                self.cacheSizeLabel.text = sizeOnDisk
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCacheSizeLabelText()

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        print("Selected cell \(indexPath.row)")
        
        switch indexPath.row {
        case 0:
            cleanCacheAndRealmData()
        case 1:
            showLogOutAlert()
        default :
            break
            
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    
    
}
