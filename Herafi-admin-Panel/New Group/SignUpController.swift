//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by Mohsen Qaysi on 10/20/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class SignUpController: UIViewController {

    let plusephotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handelPlusePhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handelPlusePhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController,animated: true, completion: nil)
    }
    
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
    
    @objc func handelTextinputChanged(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            userNameTextField.text?.count ?? 0 > 0 &&
            passWordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "الأسم"
        tf.textAlignment = .right
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
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("تسجيل", for: .normal)
        button.layer.cornerRadius = 7
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handelSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .right
        let attributedText = NSMutableAttributedString(string: "يوجد لدي حساب؟  ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
        attributedText.append(NSMutableAttributedString(string: "سجل دخول. ", attributes: [NSAttributedString.Key.foregroundColor :  UIColor.rgb(red: 17, green: 154, blue: 237), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handeShowSignIn), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handeShowSignIn(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handelSignUp() {
        guard let email = emailTextField.text, email.count > 0 else {
            print("email is emapty")
            return
        }
        guard let username = userNameTextField.text, username.count > 0 else {
            print("username is emapty")
            return
        }
        guard let password = passWordTextField.text, password.count >= 6 else {
            print("password is must be 6 charactors at least...")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                if let error = error {
                    debugPrint("User creation error: \(error.localizedDescription)")
                    return
                }
            }
            
            guard let image = self.plusephotoButton.imageView?.image else {return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            let filename = UUID().uuidString
            let riversRef = Storage.storage().reference().child("profile_images").child(filename)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            riversRef.putData(uploadData, metadata: metadata, completion: { (metadata, err) in
                if let err = err {
                    print("Failed to save user info to databse \(err)")
                    return
                }
                
                riversRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("Failed to get image download url:",err)
                        return
                    }
                    
                    guard let url = url?.absoluteString else {return}
                    print("Sccessfully downlaoded user image URL from storage:", url)
                    guard let uid = user?.user.uid else {return}
                    print("User UID: \(uid)")
                   
                    // get the fcmToken for the user device 
                    guard let fcmToken = Messaging.messaging().fcmToken else {return}
                    
                    let dictionaryVlaues = ["username": username, "profileImageUrl": url, "fcmToken": fcmToken]
                    let values = [uid: dictionaryVlaues]
                    
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if let err = err {
                            print("Failed to save user info to databse \(err)")
                            return
                        }
                        print("Sccessfully saved user info into db")
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                        mainTabBarController.setupViewController()
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // add the plusephotoButton view to the main view
        view.addSubview(plusephotoButton)
        // use anchors
        plusephotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        NSLayoutConstraint.activate([
            plusephotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        // MARK:- Set up sign up stack view
        setUpInputFields()
        
        view.addSubview(alreadyHaveAccoutButton)
        alreadyHaveAccoutButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 30, paddingRight: 12, width: 0, height: 50)
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.addSubview(topDividerView)
        topDividerView.anchor(top: nil, left: view.leftAnchor, bottom: alreadyHaveAccoutButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    fileprivate func setUpInputFields(){
        // MARK:- Stack View Sign   Up Page
        let stackView = UIStackView(arrangedSubviews: [emailTextField, userNameTextField,passWordTextField,signUpButton])
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.axis = .vertical
        
        //  add the stackView view to the main view
        view.addSubview(stackView)
        stackView.anchor(top: plusephotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
}

extension SignUpController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // check for edited frist
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusephotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusephotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusephotoButton.layer.cornerRadius = plusephotoButton.frame.width / 2
        plusephotoButton.layer.masksToBounds = true
        plusephotoButton.layer.borderColor = UIColor.black.cgColor
        plusephotoButton.layer.borderWidth = 1
        dismiss(animated: true, completion: nil)
    }
}
