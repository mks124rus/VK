//
//  LoginFromController.swift
//  Vkontakte
//
//  Created by Максим Валюшко on 05.02.2021.
//

import UIKit

class LoginFromController: UIViewController {
    
    @IBOutlet weak private var loginInput: UITextField!
    @IBOutlet weak private var passwordInput: UITextField!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var loginButtonVKweb: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView?.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @objc func keyboardWasShown(notification: Notification) {
        
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        
        self.scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        
        let contentInsets = UIEdgeInsets.zero
        scrollView?.contentInset = contentInsets
    }
    
    @objc func hideKeyboard() {
            self.scrollView?.endEditing(true)
        }
    
    func checkUserDara() -> Bool {
       guard let login = loginInput.text,
             let password = passwordInput.text else {return false}
        
        if login == "admin" && password == "123456" {
           print("Успешная авторизация!")
            return true
        } else {
            print("Вы ввели неправильный логин или пароль!")
            return true
        }
    }
    
    func loginPasswordInputLoginErrorAnimation(){
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [0, 5, -5, 5, 0]
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.duration = 0.15
        animation.isAdditive = true
        
        self.passwordInput.layer.add(animation, forKey: nil)
        self.loginInput.layer.add(animation, forKey: nil)
    }
    
    func loginButtonAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 50
        animation.mass = 1
        animation.duration = 0.45
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        self.loginButton.layer.add(animation, forKey: nil)
        
    }
    func loginButtonVKwebAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 50
        animation.mass = 1
        animation.duration = 0.45
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        self.loginButtonVKweb.layer.add(animation, forKey: nil)
        
    }
    
    func showLoginError() {
        let alert = UIAlertController(title: "Ошибка", message: "Неправильный логин или пароль!", preferredStyle: .alert)
        let action = UIAlertAction(title: "ОК", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if checkUserDara() {return true}
        loginPasswordInputLoginErrorAnimation()
        showLoginError()
        return false
    }
    
    @IBAction func logginButtonVKwebPressed(_ sender: UIButton) {
        loginButtonVKwebAnimation()
        guard let VKloginVC = storyboard?.instantiateViewController(identifier: "VKloginVC") as? VKLoginViewController else { return }
        show(VKloginVC, sender: nil)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        loginButtonAnimation()
    }
}
