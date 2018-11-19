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
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        
        fetchCompletedOrders()
        setupReloadDataButton()
    }
    
    fileprivate func setupReloadDataButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "refreash"), style: .plain, target: self, action: #selector(fetchCompletedOrders))
    }

    let indecator: UIActivityIndicatorView  = { return UIActivityIndicatorView(style: .whiteLarge)}()
    let indecatorLable: UILabel = {
        let lable = UILabel()
        lable.text = "جاري التحميل..."
        lable.font = UIFont.boldSystemFont(ofSize: 20)
        lable.textAlignment = .center
        lable.textColor = .white
        return lable
    }()
    
    lazy var activityIndecatroView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .black //UIColor.rgb(red: 17, green: 154, blue: 237,alpha: 0.4)
        view.alpha = 0.4
        
        view.addSubview(indecator)
        indecator.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 0, paddingRight: 4, width: 0, height: 0)
        
        view.addSubview(indecatorLable)
        indecatorLable.anchor(top: indecator.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc fileprivate func fetchCompletedOrders() {
        view.addSubview(activityIndecatroView)
        NSLayoutConstraint.activate([
            activityIndecatroView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndecatroView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndecatroView.heightAnchor.constraint(equalToConstant: 100),
            activityIndecatroView.widthAnchor.constraint(equalToConstant: 150),
            ])
        
         indecator.startAnimating()
        
        completedOrdersList = []
        Database.fetchOrders(path: "completedOrdersTest") { (snapshots) in
            for snapshot in snapshots {
                self.fetchOrdersHistory(snapshot: snapshot, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
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
        
        //MARK: - push data to the order view
        let orderController = OrderController()
        orderController.acceptButton.isHidden = true
        orderController.rejectButton.isHidden = true
        orderController.order = completedOrdersList[indexPath.item]
        orderController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(orderController, animated: true)
    }
}
