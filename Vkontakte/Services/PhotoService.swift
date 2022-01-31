//
//  PhotoService.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 08.06.2021.
//

import UIKit
import Alamofire

class ThreadSafeMemoryCache {
    private let quene = DispatchQueue(label: "vk.cache.isolation", attributes: .concurrent)
    
    var cache = [String: UIImage]()
    
    func get(for key: String) -> UIImage? {
        var image: UIImage?
        quene.sync {
            image = self.cache[key]
        }
        return image
    }
    
    func set(image: UIImage?, for key: String){
        quene.async(flags: .barrier) {
            self.cache[key] = image
        }
    }
}


class PhotoService {
    
    static let instance = PhotoService()
    private static var memoryCache = ThreadSafeMemoryCache()
    private init(){}
    
    private let cacheLifetime: TimeInterval = 30*24*60*60 //дни * часы * минуты * секунды
    private let filemngr = FileManager.default
    
    
    /// URL  /Library/Caches/Images
    public var imageCacheURL: URL? {
        let dirname = "Images"
        guard let cacheDir = filemngr.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
        let url = cacheDir.appendingPathComponent(dirname, isDirectory: true)
        
        if !filemngr.fileExists(atPath: url.path){
            do {
                try filemngr.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        return url
    }
    
    
    ///Delete directory "Images" in /Library/Caches/
    public func clearCache(){
        guard let url = imageCacheURL else {return}
        
        if filemngr.fileExists(atPath: url.path){
            do {
                try filemngr.removeItem(at: url)
                print("'Images' is delete...")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getFilePath(stringURL: String) -> URL? {
        
        let url = URL(string: stringURL)
        let filename = url?.lastPathComponent ?? ""
        guard let imageCacheURL = self.imageCacheURL else {return nil}
        return imageCacheURL.appendingPathComponent(filename)
    }
    
    private func saveImageToFilesystem(stringURL: String, image: UIImage) {
        
        guard let data = image.pngData(),
              let fileURL = getFilePath(stringURL: stringURL) else {
            return
        }
        try? data.write(to: fileURL)
    }
    
    private func loadImageFromFilesystem(stringURL: String) -> UIImage? {
        
        guard let filePath = getFilePath(stringURL: stringURL),
              let info = try? filemngr.attributesOfItem(atPath: filePath.path),
              let modificationDate = info[.modificationDate] as? Date,
              cacheLifetime > Date().distance(to: modificationDate),
              let image = UIImage(contentsOfFile: filePath.path) else { return nil }
        
        return image
    }
    
    private func loadImage(stringURL: String, completion: @escaping (UIImage) -> Void){
        AF.request(stringURL).responseData(queue: .global()) { [weak self] response in
            switch response.result {
            case .success(let data):
                guard let image = UIImage(data: data) else {return}
                self?.saveImageToFilesystem(stringURL: stringURL, image: image)
                completion(image)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    public func photo(stringURL: String, completion: @escaping (UIImage) -> Void) {
        
        if let image = PhotoService.memoryCache.get(for: stringURL){
            completion(image)
        } else if let image = self.loadImageFromFilesystem(stringURL: stringURL) {
            completion(image)
        } else {
            self.loadImage(stringURL: stringURL, completion: completion)
        }
    }
}



