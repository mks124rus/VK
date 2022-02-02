//
//  NewsViewModel.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 02.02.2022.
//

import Foundation
import UIKit

struct NewsViewModel {
    var date: Int
    var text: String?
    var commentsCount, likesCount, repostsCount : String
    var name: String
    var avatarURL: String?
    var photoPostURL: String?
    var photoHeight: Int?
    var photoWidth: Int?
}
