//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Mohsen Qaysi on 11/2/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginContoller = LoginContoller()
                let navController = UINavigationController(rootViewController: loginContoller)
                self.present(navController, animated: true, completion: nil)
                return
            }
        }
        
        setupViewController()
    }
    
    func setupViewController(){
        //MARK: UICollectionViewFlowLayout is very important and NOT UICollectionViewLayout
        // user profile
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: userProfileController)
        navController.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        tabBar.tintColor = .black
        viewControllers = [navController]
    }
}
