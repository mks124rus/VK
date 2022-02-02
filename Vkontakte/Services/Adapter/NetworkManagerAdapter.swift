//
//  NetworkManagerAdapter.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 01.02.2022.
//

import Foundation
import RealmSwift

struct GroupAdapter {
    var id: Int
    var name: String
    var avatar: String
}

final class NetworkManagerAdapter {
    
    private let networkManager = NetworkManager.shared
    private var realmManager = RealmManager.shared
    
    func getMyGroups(completion: @escaping ([GroupAdapter]) -> Void) {
        guard let realmManager = RealmManager.shared else {return}
        let resultsGroup: Results<Group>? = realmManager.getObjects()
        
        guard let rlmGroup = resultsGroup else {return}
            
            networkManager.loadGroups {result in
                switch result {
                case .success(let groupsArray):
                    try? self.realmManager?.add(objects: groupsArray)
                    var groups: [GroupAdapter] = []
                    for group in rlmGroup {
                        groups.append(self.myGroups(from: group))
                    }
                    completion (groups)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
    }
    
    
    private func myGroups(from rlmGroups: Group) -> GroupAdapter {
        
        return GroupAdapter(id: rlmGroups.id, name: rlmGroups.name, avatar: rlmGroups.avatar)
        
    }
    
    
    
    
}
