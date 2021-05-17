//
//  Group.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 11.02.2021.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Group: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var avatar: String = ""
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    convenience init(from json: JSON ) {
        self.init()
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.avatar = json["photo_50"].stringValue
    }
}

enum groupsLogo: String {
    case cartuning = "cartuning.jpg"
    case muisc = "muisc.jpg"
    case games = "games.png"
    case news = "news.png"
    case none = "none.jpg"
}

struct Groups {
    var name: String
    var logo: groupsLogo
    var postText: String?
    var postPhoto: UIImage?
    
    static func createMyGroups() -> [Groups] {
        return [Groups(name: "News", logo: .news, postText: """
                       На Землю может упасть "неконтролируемая" китайская ракета "Чанчжэн-5"
                       """, postPhoto: UIImage(named: "")),
                Groups(name: "Music", logo: .muisc, postText: "", postPhoto: UIImage(named: "car5")),
                Groups(name: "Games", logo: .games, postText: """
                        КОНСОЛИ ПРОШЛОГО ПОКОЛЕНИЯ НЕ ПОТЯНУЛИ БЫ S.T.A.L.K.E.R. 2, А ВЕРСИЯ ДЛЯ PLAYSTATION 5 ПОКА НЕ ПЛАНИРУЕТСЯ
                        """, postPhoto: UIImage(named: "")),
                Groups(name: "CarTuning", logo: .cartuning, postText: "Look at this Audi S5! She is AMAaaaaazing!!! 💙💙💙", postPhoto: UIImage(named: "car6")),].sorted(by: {$0.name < $1.name})
    }
    static func createGlobalGroups() -> [Groups] {
        return [Groups(name: "Global news", logo: .none, postText: "", postPhoto: UIImage(named: "")),
                Groups(name: "Dance", logo: .none, postText: "", postPhoto: UIImage(named: "")),
                Groups(name: "RacingTeam", logo: .none, postText: "", postPhoto: UIImage(named: "")),
                Groups(name: "Programs", logo: .none, postText: "", postPhoto: UIImage(named: ""))].sorted(by: {$0.name < $1.name})
    }
}

var myGroups = Groups.createMyGroups()
var globalGroups = Groups.createGlobalGroups()


