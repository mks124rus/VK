//
//  ImageCache.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 17.05.2021.
//

import Foundation

class ImageCache {
    static let instance = ImageCache()
    private init(){
        
    }
    
    var cache: [String: Data] = [:]
}
