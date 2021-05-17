//
//  News.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 11.05.2021.
//

import Foundation
import SwiftyJSON

final class News {
    var sourceID, date: Int
    var text: String?
    var commentsCount, likesCount, repostsCount : Int
    var name: String
    var avatar: String?
    var photoURL: String?
    var photoHeight: Int?
    var photoWidth: Int?
    
    init(from json: JSON) {
            self.sourceID = json["source_id"].intValue
            self.date = json["date"].intValue
            self.text = json["text"].stringValue
            self.commentsCount = json["comments","count"].intValue
            self.likesCount = json["likes","count"].intValue
            self.repostsCount = json["reposts","count"].intValue
            self.name = json["name"].stringValue
            self.avatar = json["photo_50"].stringValue

            if json["type"] == "post" {
                for size in json["attachments"][0]["photo"]["sizes"].arrayValue {
                    if size["type"].stringValue == "x" {
                        self.photoURL = size["url"].stringValue
                        self.photoHeight = size["height"].intValue
                        self.photoWidth = size["width"].intValue
                    } else {
                        for size in json["photos"]["items"][0]["sizes"].arrayValue {
                            if size["type"].stringValue == "x" {
                                self.photoURL = size["url"].stringValue
                                self.photoHeight = size["height"].intValue
                                self.photoWidth = size["width"].intValue
                        }
                    }
                }
            }
        }
    }
}
