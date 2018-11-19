//
//  OrdersHistoryCollectionViewController.swift
//  Herafi-admin-Panel
//
//  Created by Mohsen Qaysi on 11/17/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase

private let historyCell = "historyCell"

class OrdersHistoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var completedOrdersList =  [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .lightGray
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

         // Register cell classes
        self.collectionView.register(MainOrderCell.self, forCellWithReuseIdentifier: historyCell)
       
        // Register nib classes
        //        let nibCell = UINib(nibName: "HistoryCollectionCell", bundle: nil)
        //        self.collectionView!.register(nibCell, forCellWithReuseIdentifier: historyCell)
        
        fetchCompletedOrders()
        setupReloadDataButton()
    }
    
    fileprivate func setupReloadDataButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(fetchCompletedOrders))
    }

    
    @objc fileprivate func fetchCompletedOrders() {
        completedOrdersList = []
        Database.fetchOrders(path: "completedOrdersTest") { (snapshots) in
            for snapshot in snapshots {
                self.fetchOrdersHistory(snapshot: snapshot)
            }
        }
    }
    

    fileprivate func fetchOrdersHistory(snapshot: DataSnapshot){
        guard let dictionary = snapshot.value as? [String: Any] else {return}
        print("fetchOrdersHistory dictionary: ", dictionary)

        let order = Order(key: snapshot.key, dictionary: dictionary)
//        let order = TimeStamp(key: snapshot.key, dictionary: dictionary)
//        print("order TimeStamp: ", order)
        self.completedOrdersList.insert(order, at: 0)
        self.collectionView.reloadData()
    }
    
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return completedOrdersList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: historyCell, for: indexPath) as! MainOrderCell
    
        cell.orderCompleted = completedOrdersList[indexPath.item]
        cell.newOrderIcon.isHidden = true
        
        
//        cell.messageLabel.text = completedOrdersList[indexPath.item].message
//        cell.serviceLabel.text = completedOrdersList[indexPath.item].service
//        cell.orderStatusButton.setTitle("مغلق", for: .normal)
//        cell.orderStatusButton.setTitleColor(.red, for: .normal)
//        cell.nameLabel.text = completedOrdersList[indexPath.item].name
//        let date = completedOrdersList[indexPath.item].dateNow
//        print("date: ", date)
//        cell.datelabel.text = String.convertDate(currentTimeInMiliseconds: date)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)
        return CGSize(width: width, height: 60)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
