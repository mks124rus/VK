//
//  GetDataOperation.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 25.05.2021.
//

import Foundation
import Alamofire

class GetDataOperation: AsyncOperation {

    private var request: DataRequest
    var data: Data?
    
    override func main() {
        request.responseData(queue: DispatchQueue.global()) { [weak self] response in
            switch response.result{
            case .success(let data):
                self?.data = data
                self?.state = .finished
            case .failure(let error):
                print(error.localizedDescription)
            }
//            self?.data = response.data
//            self?.state = .finished
        }
    }
    
    override func cancel() {
        request.cancel()
        super.cancel()
    }
    
    init(request: DataRequest) {
        self.request = request
    }
    
}
