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
        collectionView.backgroundColor = .white
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

         // Register cell classes
        self.collectionView.register(MainOrderCell.self, forCellWithReuseIdentifier: historyCell)
       
        // Register nib classes
        //        let nibCell = UINib(nibName: "HistoryCollectionCell", bundle: nil)
        //        self.collectionView!.register(nibCell, forCellWithReuseIdentifier: historyCell)
        
        navigationItem.title = "الطلبات المغلقة"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        fetchCompletedOrders()
        setupReloadDataButton()
    }
    
    fileprivate func setupReloadDataButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refreash").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(fetchCompletedOrders))
    }

    let indecator: UIActivityIndicatorView  = { return UIActivityIndicatorView(style: .whiteLarge)}()
    let indecatorLable: UILabel = {
        let lable = UILabel()
        lable.text = "جاري التحميل..."
        lable.font = UIFont.boldSystemFont(ofSize: 18)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var activityIndecatroView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        
        view.addSubview(indecator)
        indecator.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 2, paddingBottom: 0, paddingRight: 2, width: 100, height: 100)
        
        view.addSubview(indecatorLable)
        indecatorLable.anchor(top: indecator.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc fileprivate func fetchCompletedOrders() {
        

        
        view.addSubview(activityIndecatroView)
        NSLayoutConstraint.activate([
            activityIndecatroView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndecatroView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndecatroView.heightAnchor.constraint(equalToConstant: 140),
            activityIndecatroView.widthAnchor.constraint(equalToConstant: 140),
            ])
        
         indecator.startAnimating()
        
        completedOrdersList = []
        Database.fetchOrders(path: "completedOrdersTest") { (snapshots) in
            for snapshot in snapshots {
                self.fetchOrdersHistory(snapshot: snapshot, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        self.indecator.stopAnimating()
                        self.activityIndecatroView.removeFromSuperview()
                    })
                })
            }
        }
    }
    

    fileprivate func fetchOrdersHistory(snapshot: DataSnapshot, completion: @escaping () -> () ){
        guard let dictionary = snapshot.value as? [String: Any] else {return}

        let order = Order(key: snapshot.key, dictionary: dictionary)
        self.completedOrdersList.insert(order, at: 0)
        self.collectionView.reloadData()
        completion()
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
        cell.newOrderIcon.image = #imageLiteral(resourceName: "doneIcon")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)
        return CGSize(width: width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if let cell = collectionView.cellForItem(at: indexPath) as? MainOrderCell {
//            cell.newOrderIcon.isHidden = true
//        }
        
        //MARK: - push data to the order view
        let orderController = OrderController()
        orderController.acceptButton.isHidden = true
        orderController.rejectButton.isHidden = true
        orderController.order = completedOrdersList[indexPath.item]
        orderController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(orderController, animated: true)
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
