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
        
        let userNavProfileController = templeteNavContrller(selectedImage: #imageLiteral(resourceName: "profile_selected"), unselectedImage: #imageLiteral(resourceName: "profile_unselected"), title: "الطلبات المفتوحة", rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let historyOrdersNavController = templeteNavContrller(selectedImage: #imageLiteral(resourceName: "order_selected"), unselectedImage: #imageLiteral(resourceName: "order_unselected"), title: "الطلبات المقفلة", rootViewController: OrdersHistoryCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))

        //MARK: UICollectionViewFlowLayout is very important and NOT UICollectionViewLayout
        // user profile
        
        tabBar.tintColor = .black
        viewControllers = [userNavProfileController,historyOrdersNavController]
        
        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
        
    }
    
    fileprivate func templeteNavContrller(selectedImage: UIImage, unselectedImage: UIImage, title: String?, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        if let title = title {
            navController.tabBarItem.title = title
        }
        return navController
    }
}
