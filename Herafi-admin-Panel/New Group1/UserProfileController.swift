//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Mohsen Qaysi on 11/2/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase

extension Database {
    static func fetchOrderDataWithId(orderId: String, path: String, completion: @escaping (Order) -> ()) {
        Database.database().reference().child(path).child(orderId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictonary =  snapshot.value as? [String: Any] else {return}
            let order = Order(key: orderId, dictionary: dictonary)
            completion(order)
        }) { (err) in
            print("Failed to fetch order data", err)
        }
    }
    
    static func fetchOrders(path: String, completion: @escaping ([DataSnapshot]) -> ()) {
        var comletedOrders = [DataSnapshot]()
        Database.database().reference().child(path).observeSingleEvent(of: .value, with: { (snapshots) in
            
            //TODO: Cehck the casting values on line 31
            for child in snapshots.children {
                guard let snapshot = child as? DataSnapshot else {return}
                
                if let timeStamp = snapshot.value as? String {
                    print("snapshot timeStamp: \(snapshot)")
                }
                
                comletedOrders.insert(snapshot, at: 0)
            }
            completion(comletedOrders)
        }) { (err) in
            print("Failed to fetch order data", err)
        }
    }
}

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let headerId = "headerId"
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().child("ordersTest").observe(DataEventType.childAdded) { (snapshot) in
            self.fetchOrdersAdded(snapshot: snapshot)
        }
        
        Database.database().reference().child("ordersTest").observe(DataEventType.childRemoved) { (snapshot) in
            let index = self.ordersList.index{ $0.key == snapshot.key}
            if let index = index {
                self.ordersList.remove(at: index)
            }
            self.collectionView.reloadData()
        }
        
        Database.database().reference().child("completedOrdersTest").observe(DataEventType.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let order = Order(key: snapshot.key, dictionary: dictionary)
            self.completedOrdersList.append(order)
            self.collectionView.reloadData()
        }
        
        Database.database().reference().child("completedOrdersTest").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let order = Order(key: snapshot.key, dictionary: dictionary)
            print("completedOrdersTest \(order)")
            self.completedOrdersList.append(order)
            self.collectionView.reloadData()
        }, withCancel: { (err) in
            print(err)
        })
        
        collectionView.backgroundColor = .white
        navigationItem.title = Auth.auth().currentUser?.uid
        
        fetchUser()
        
        
        // MARK: - register the header view
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: headerId)
        
        //TODO:- Create a new cell to holde the order info
        collectionView.register(MainOrderCell.self, forCellWithReuseIdentifier: cellId)
        
        setupLogOutButton()
    }
    
    fileprivate func setupLogOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handelLogOut))
    }
    
    @objc func handelLogOut() {
        let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertSheet.addAction(UIAlertAction(title: "تسجيل خروج", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                // MARK:- Log Out
                
                // what hapen? we need to present some kind of log in controller
                let loginController = LoginContoller()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: {
                    // Set the badge to 0 when loggin out a user
                    UIApplication.shared.applicationIconBadgeNumber = 0
                })
            } catch let err {
                print("Falid to log user out", err)
            }
        }))
        
        alertSheet.addAction(UIAlertAction(title: "الغاء", style: .cancel, handler: nil))
        present(alertSheet, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ordersList.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MainOrderCell
        cell.order = ordersList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)
        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.orderStatus = "\(ordersList.count)"
        header.orderStatusCompleeted = "\(completedOrdersList.count)"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? MainOrderCell {
            cell.newOrderIcon.isHidden = true
        }
        
        //MARK: - push data to the order view
        let orderController = OrderController()
        orderController.order = ordersList[indexPath.item]
        orderController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(orderController, animated: true)
    }
    
    var user: User?
    fileprivate func fetchUser(){
        guard let uid =  Auth.auth().currentUser?.uid else {
            print("No currect user available")
            return
        }
        //MARK: get user profile info
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            self.user = User(dictionary: dictionary)
            self.navigationItem.title = self.user?.username
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Faild to fetch user:", err)
        }
    }
    
    var order: Order?
    var ordersList = [Order]()
    
    fileprivate func fetchOrdersAdded(snapshot: DataSnapshot){
        guard let dictionary = snapshot.value as? [String: Any] else {return}
        let order = Order(key: snapshot.key, dictionary: dictionary)
        self.ordersList.insert(order, at: 0)
        self.collectionView.reloadData()
    }
    
    var completedOrder: Order?
    var completedOrdersList = [Order]()
    fileprivate func fetchCompletedOrders(){
        completedOrdersList = []
        //MARK: get user profile info
        Database.database().reference().child("completedOrdersTest").observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            dictionary.forEach({ (key, order) in
                let order = Order(key: key, dictionary: order as! [String : Any])
                self.completedOrdersList.append(order)
            })
            
            self.collectionView.reloadData()
            
        }) { (err) in
            print("Faild to fetch user:", err)
        }
    }
}

struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}

struct Order {
    let key: String
    let name: String
    let phone: String
    let service: String
    let message: String
    let dateNow: Double
    let orderStatutsAccepted: String
    
    init(key: String, dictionary: [String: Any]) {
        self.key = key
        self.name = dictionary["name"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.service = dictionary["service"] as? String ?? ""
        self.message = dictionary["message"] as? String ?? ""
        self.orderStatutsAccepted = dictionary["orderStatutsAccepted"] as? String ?? ""
        self.dateNow = dictionary["timeStamp"] as? Double ?? 0
    }
    
}


extension String {
    static func convertDate(currentTimeInMiliseconds: TimeInterval) -> String? {
        let dateTimeStamp = Date(timeIntervalSince1970: Double(currentTimeInMiliseconds)/1000)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let strDateSelect = dateFormatter.string(from: dateTimeStamp)
        return strDateSelect
    }
}
