//
//  NetworkManager.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 22.03.2021.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

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
    
    //аватар друга
    func loadFriendsAvatar(token: String) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/friends.get"
        urlComponents.queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "fields", value: "photo_50"),
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
    //получаем данные из url
    func getImageData(stringURL: String) -> Data {
        guard let url = URL(string: stringURL) else { return Data() }
        guard let imageData = try? Data(contentsOf: url) else { return Data() }
        return imageData
    }
    
    //новости
    func loadNewsFeed(token: String, startTime: Double? = nil, startFrom: String, completion: @escaping (Swift.Result<[News], Error>, String) -> Void) {

            let baseURL = "https://api.vk.com"
            let path = "/method/newsfeed.get"
            
        var params: Parameters = [
                "access_token": token,
                "start_from": startFrom,
                "max_photos": "1",
                "filters": "post, photo",
                "return_banned" : "0",
                "count" : "25",
                "v" : "5.130"
            ]
        
        if let startTime = startTime {
            params["start_time"] = startTime
        }
            
        AF.request(baseURL + path, method: .get, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
    
                var news = [News]()
                
                var users = [User]()
                var groups = [Group]()
                let nextFrom = json["response"]["next_from"].stringValue
                
                let parsingGroup = DispatchGroup()
                
                DispatchQueue.global().async(group: parsingGroup) {
                    users = json["response","profiles"].arrayValue.map { User(from: $0) }
                }
                DispatchQueue.global().async(group: parsingGroup) {
                    groups = json["response", "groups"].arrayValue.map { Group(from: $0)}
                }
                
                parsingGroup.notify(queue: .global()){
                    news = json["response","items"].arrayValue.map { News(from: $0)}
                    
                    self.sourcePostIdentify(news: news, user: users, group: groups)
                    DispatchQueue.main.async {
                        completion(.success(news), nextFrom)
                    }
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error), "")
            }
        }
    }
    
    //определяем владельца поста: группа или друг
    private func sourcePostIdentify(news: [News], user: [User], group: [Group]){
        for post in news{
            if post.sourceID > 0 {
                let index = user.firstIndex(where: {item -> Bool in
                    item.id == post.sourceID
                })
                post.name = "\(user[index ?? 0].firstLastName)"
                post.avatar = "\(user[index ?? 0].avatar)"
            } else {
                let index = group.firstIndex(where: {item -> Bool in
                    item.id == post.sourceID * -1
                })
                post.name = "\(group[index ?? 0].name)"
                post.avatar = "\(group[index ?? 0].avatar)"
            }
        }
    }
    
    //фото друзей
    func loadFriendPhotos(userID: String, completion: ((Swift.Result<[Photo], Error>) -> Void)? = nil){
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
    //список друзей
    func loadFriends(completion: ((Swift.Result<[User], Error>) -> Void)? = nil){
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
    
    func loadFriendsOperations() -> DataRequest?{
        guard let token = token else {return nil}
        
        let baseURL = "https://api.vk.com"
        let path = "/method/friends.get"
        
        let params: Parameters = [
            "access_token": token,
            "fields": "photo_50",
            "order": "name",
            "v" : "5.130"
        ]
        
        return AF.request(baseURL + path, method: .get, parameters: params)
    }
    
    func loadFriendsPhotoOperations(userID: String) -> DataRequest?{
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
        
        return AF.request(baseURL + path, method: .get, parameters: params)
    }
    
    //promise
    func loadGroupsPromise() -> Promise<[Group]>{
        
        let baseURL = "https://api.vk.com"
        let path = "/method/groups.get"
        
        let params: Parameters = [
            "access_token": "\(self.token ?? "")",
            "extended": 1,
            "v" : "5.130"
        ]
        
        let promise = Promise<[Group]> { resolve in
            AF.request(baseURL + path, method: .get, parameters: params)
                .responseJSON { response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let groupsJSON = json["response","items"].arrayValue
                    let groups = groupsJSON.map { Group(from: $0) }
                    resolve.fulfill(groups)
                case .failure(let error):
                    resolve.reject(error)
                }
            }
        }
        return promise
    }
    
    //список групп
    func loadGroups(completion: ((Swift.Result<[Group], Error>) -> Void)? = nil){
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
