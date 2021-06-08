//
//  SaveToRealmOperation.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 25.05.2021.
//

import Foundation
import RealmSwift

class SaveToRealmOperation: Operation {
    
    override func main() {
        guard let parseUserData = dependencies.first as? ParseUserDataOperation else { return }
        try? RealmManager.shared?.add(objects: parseUserData.outputData)
    }
}
