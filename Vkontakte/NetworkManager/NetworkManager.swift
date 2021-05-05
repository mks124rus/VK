//
//  NetworkManager.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 22.03.2021.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    private static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    static let shared = NetworkManager()
    
    private init(){}
    
    var token: String?
    var userId: Int?
    
    func loadFriendsAvatar(token: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/friends.get"
        urlComponents.queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "fields", value: "photo_200"),
            URLQueryItem(name: "v", value: "5.130")
        ]
        
        guard let url = urlComponents.url else {return}
        
        let dataTask = NetworkManager.session.dataTask(with: url) {
            (data,response,error) in
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
                    print(json)
                } else if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
        dataTask.resume()
    }
    
    func getUserImageData(stringURL: String) -> Data {
//        let imageCache = ImageCache.instance
//        if imageCache.cache[stringURL] != nil {
//            return imageCache.cache[stringURL] ?? Data()
//        }
        guard let url = URL(string: stringURL) else { return Data() }
        guard let imageData = try? Data(contentsOf: url) else { return Data() }
//        imageCache.cache[stringURL] = imageData
        return imageData
    }
    
    func loadFriendPhotos(userID: String, completion: ((Result<[Photo], Error>) -> Void)? = nil){
        let baseURL = "https://api.vk.com"
        let path = "/method/photos.getAll"
        
        let params: Parameters = [
            "access_token": "\(NetworkManager.shared.token ?? "")",
            "owner_id": userID,
            "album_id" : "wall",
            "extended": "1",
            "rev" : "1",
            "count" : "50",
            "v" : "5.130"
        ]
        
        AF.request(baseURL + path, method: .get, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let usersPhotoJSON = json["response","items"].arrayValue
                let photo = usersPhotoJSON.map {Photo(from: $0) }
                completion?(.success(photo))
            case .failure(let error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
    func loadFriends(completion: ((Result<[User], Error>) -> Void)? = nil){
        let baseURL = "https://api.vk.com"
        let path = "/method/friends.get"
        
        let params: Parameters = [
            "access_token": "\(NetworkManager.shared.token ?? "")",
            "fields": "photo_50",
            "order": "name",
            "v" : "5.130"
        ]
        
        AF.request(baseURL + path, method: .get, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let usersJSON = json["response","items"].arrayValue
                let users = usersJSON.map { User(from: $0) }
                completion?(.success(users))
            case .failure(let error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
    func loadGroups(completion: ((Result<[Group], Error>) -> Void)? = nil){
        let baseURL = "https://api.vk.com"
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": "\(NetworkManager.shared.token ?? "")",
            "extended": 1,
            "v" : "5.130"
        ]
        AF.request(baseURL + path, method: .get, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let groupsJSON = json["response","items"].arrayValue
                let groups = groupsJSON.map { Group(from: $0) }
                completion?(.success(groups))
            case .failure(let error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
}

class ImageCache {
    static let instance = ImageCache()
    private init(){
        
    }
    
    var cache: [String: Data] = [:]
}
