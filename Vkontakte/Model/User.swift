//
//  User.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 10.02.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class User: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var firstname: String = ""
    @objc dynamic var lastname: String = ""
    @objc dynamic var avatar: String = ""
    @objc dynamic var firstLastName: String = ""
    
    let photos = List<Photo>()
    
    override class func primaryKey() -> String? {
       return "id"
    }
    
    convenience init(from json: JSON ) {
        self.init()
        self.id = json["id"].intValue
        self.firstname = json["first_name"].stringValue
        self.lastname = json["last_name"].stringValue
        self.avatar = json["photo_50"].stringValue
        self.firstLastName = firstname + " " + lastname
    }
}
