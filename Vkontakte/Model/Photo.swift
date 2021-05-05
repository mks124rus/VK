//
//  Photo.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 31.03.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Photo: Object {
    @objc dynamic var url: String = ""
    @objc dynamic var likeCount: Int = 0
    @objc dynamic var ownerID: Int = 0
    
    let owner = LinkingObjects(fromType: User.self, property: "photos")
    
    override class func primaryKey() -> String? {
        "url"
    }

    convenience init(from json: JSON ) {
        self.init()
        self.ownerID = json["owner_id"].intValue
        self.url = json["sizes"][4]["url"].stringValue
        if self.url == "" {
            self.url = json["sizes"][3]["url"].stringValue
            if self.url == ""{
                self.url = json["sizes"][2]["url"].stringValue
            }
        }
        self.likeCount = json["likes","count"].intValue
    }
}
