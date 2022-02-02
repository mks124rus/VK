//
//  Photo.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 31.03.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

final class Photo: Object {
    @objc dynamic var url: String = ""
    @objc dynamic var likeCount: Int = 0
    @objc dynamic var ownerID: Int = 0
    @objc dynamic var date: Int = 0
    
    let owner = LinkingObjects(fromType: User.self, property: "photos")
    
    override class func primaryKey() -> String? {
        "url"
    }

    convenience init(from json: JSON ) {
        self.init()
        self.ownerID = json["owner_id"].intValue
        
        guard let sizesArray = json["sizes"].array,
              let xSize = sizesArray.first(where: {$0["type"].stringValue == "x" }) else {return}

        self.url = xSize["url"].stringValue
        self.likeCount = json["likes","count"].intValue
        self.date = json["date"].intValue
    }
}
