//
//  LoginContoller.swift
//  InstagramFirebase
//
//  Created by Mohsen Qaysi on 11/5/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseRemoteConfig
class LoginContoller: UIViewController, UITextFieldDelegate {
    
    let logoContinerview: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Herafi_logo_black"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0 , paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "الإيميل"
        tf.textAlignment = .right
        tf.keyboardType = .emailAddress
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.addTarget(self, action: #selector(handelTextinputChanged), for: .editingChanged)
        return tf
    }()
    
    let passWordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "الرقم السري"
        tf.textAlignment = .right
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.addTarget(self, action: #selector(handelTextinputChanged), for: .editingChanged)
        return tf
    }()

    
    let forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("نسيت كلمة السر؟", for: .normal)
        button.isEnabled = false
        button.alpha = 0.5
        button.setTitleColor(UIColor.rgb(red: 17, green: 154, blue: 237), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        //        button.addTarget(self, action: #selector(handelSignUp), for: .touchUpInside)
        return button
    }()
    
    lazy var loginUpButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("تسجيل دخول", for: .normal)
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handelLogin), for: .touchUpInside)
        button.isEnabled = false
        
        button.addSubview(self.activityIndicator)
        self.activityIndicator.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        self.activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        return button
    }()
    
    @objc func handelLogin(){
        guard let email = emailTextField.text else { return }
        guard let password = passWordTextField.text else { return }
        
        activityIndicator.startAnimating()
        let isAnimating = self.activityIndicator.isAnimating
        loginButtonActivityIndicator(isAnimating)
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                print("Fialed to log in user:", err)
                self.loginButtonActivityIndicator(false)
                return
            }
            
            guard let uid = user?.user.uid else {return}
            print("Successfully")
            print(uid)
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupViewController()
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loginButtonActivityIndicator(_ isAnimating: Bool) {
        if isAnimating {
            loginUpButton.setTitle("", for: .normal)
        } else {
            loginUpButton.setTitle("تسجيل دخول", for: .normal)
            activityIndicator.stopAnimating()
        }
    }
    
    @objc func handelTextinputChanged(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            passWordTextField.text?.count ?? 0 > 0
        if isFormValid {
            loginUpButton.isEnabled = true
            loginUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginUpButton.isEnabled = false
            loginUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let dontHaveAccoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .right
        let attributedText = NSMutableAttributedString(string: "لا يوجد لديك حساب؟  ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        attributedText.append(NSMutableAttributedString(string: "سجل الأن. ", attributes: [NSAttributedString.Key.foregroundColor :  UIColor.rgb(red: 17, green: 154, blue: 237), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handeShowSignup), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handeShowSignup(){
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    fileprivate func showRegisterButton(flag: Bool) {
        if flag {
            view.addSubview(dontHaveAccoutButton)
            dontHaveAccoutButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 30, paddingRight: 12, width: 0, height: 50)
            
            let topDividerView = UIView()
            topDividerView.backgroundColor = UIColor(white: 0, alpha: 0.2)
            view.addSubview(topDividerView)
            topDividerView.anchor(top: nil, left: view.leftAnchor, bottom: dontHaveAccoutButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
            
        }
    }
    
    func updateViewWithRCvalues() {
        let flag = RemoteConfig.remoteConfig().configValue(forKey: "showRegisterButtonFlag").boolValue
        print("flag: ", flag)
        showRegisterButton(flag: flag)
    }
    
    func setupRemoteConfigDefulats() {
        let defaultvalues: [String: Any?] = [
            "showDontHaveAccoutButton": true
        ]
        
        RemoteConfig.remoteConfig().setDefaults(defaultvalues as? [String : NSObject])
    }
    
    func fetchRemoteConfig() {
        //TODO: Chnage this in poduction
        let debugSettings = RemoteConfigSettings(developerModeEnabled: true)
        RemoteConfig.remoteConfig().configSettings = debugSettings
       
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: 0) { [unowned self ] (status, err) in
            if let err = err {
                print("Failed to fetech remoteConfig:", err)
                return
            }
            print("activiate the new settings")
            RemoteConfig.remoteConfig().activateFetched()
            self.updateViewWithRCvalues()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Read and set configirations from firebase config
        setupRemoteConfigDefulats()
        updateViewWithRCvalues()
        fetchRemoteConfig()
        
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(logoContinerview)
        logoContinerview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 150, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
         setupInputsFields()
        
        passWordTextField.delegate = self
        passWordTextField.tag = 0
        emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
 
    fileprivate func setupInputsFields(){
        let forgotpassStack = UIStackView(arrangedSubviews: [forgetPasswordButton])
        forgotpassStack.axis = .vertical
        forgotpassStack.alignment = .trailing
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passWordTextField,forgotpassStack,loginUpButton])
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: logoContinerview.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 190)
    }
}
