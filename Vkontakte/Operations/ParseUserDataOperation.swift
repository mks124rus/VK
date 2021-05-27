//
//  ParseUserDataOperation.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 25.05.2021.
//

import Foundation
import SwiftyJSON

class ParseUserDataOperation: Operation {
    
    var outputData: [User] = []
    
    override func main() {
        guard let getDataOperation = dependencies.first as? GetDataOperation,
              let data = getDataOperation.data else { return }
        let json = JSON(data)
        let usersJSON = json["response","items"].arrayValue
        let users = usersJSON.map { User(from: $0) }
        self.outputData = users
    }
}
