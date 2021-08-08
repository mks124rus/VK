//
//  VKLoginViewController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 25.03.2021.
//

import UIKit
import WebKit


class VKLoginViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!{
        didSet{
            webView.navigationDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "7808092"),
            URLQueryItem(name: "scope", value: "270342"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.130")
        ]
        
        guard let url = components.url else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)

    }
    
    func moveToTabBarController() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarController") as? UITabBarController else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension VKLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url,
              url.path == "/blank.html",
              let fragment = url.fragment else {
            decisionHandler(.allow)
            
            return
        }
        print (fragment)
        
        let params = fragment
            .components(separatedBy: "&")
            .map {$0.components(separatedBy: "=")}
            .reduce([String: String]()) {result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
            
                return dict
            }
        
        print(params)
        
        guard  let token = params["access_token"],
               let userIdString = params["user_id"],
               let userID = Int(userIdString) else {
            decisionHandler(.allow)
            return
        }
        NetworkManager.shared.token = token
        NetworkManager.shared.userId = Int(userID)

        decisionHandler(.cancel)
        
        if NetworkManager.shared.token != nil,
           NetworkManager.shared.userId != nil {
            self.moveToTabBarController()
        }
    }
    
    
}

