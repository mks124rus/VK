//
//  ReloadsMyFriendsController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 25.05.2021.
//

import Foundation

class ReloadMyFriendsController: Operation {
    var controller: MyFriendsController
    
    init(controller: MyFriendsController) {
        self.controller = controller
    }
    
    override func main() {
        guard let parseUserData = dependencies.first as? ParseUserData else { return }
        controller.users = parseUserData.outputData
        print(controller.users)
        controller.myFriendsTableView.reloadData()
  
  }
}
