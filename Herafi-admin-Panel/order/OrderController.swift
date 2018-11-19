//
//  OrderController.swift
//  HerafiAdmin
//
//  Created by Mohsen Qaysi on 11/8/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit
import Firebase

class OrderController: UIViewController {
    
    var order: Order? {
        didSet{
            
            guard let date = order?.dateNow else {return}
            print("MainOrderCell timeStamp:", date)
            guard let convertedDate = String.convertDate(currentTimeInMiliseconds: date) else {return}
             orderDateLable.text = convertedDate
            
            nameLable.text = order?.name
            servieLable.text = order?.service
            guard let messageCount = order?.message.count else { return }
            print("messageCount:",messageCount)
            if messageCount > 0 {
                messageTextView.text = order?.message
                view.addSubview(messageTitleLabel)
                messageTitleLabel.anchor(top: servieLable.bottomAnchor, left: servieLable.leftAnchor, bottom: nil, right: servieLable.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 40)
                view.addSubview(messageTextView)
                messageTextView.anchor(top: messageTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 200)
            }
        }
    }
    
    let orderDataLableOrderTitleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "تاريخ الطلب", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let orderDateLable: UILabel = {
        let label = UILabel()
        label.text = "order data"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let nameTitleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "إسم العميل", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let nameLable: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let serviceTitleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "نوع الطلب", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let servieLable: UILabel = {
        let label = UILabel()
        label.text = "service"
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let messageTitleLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "وصف المشكلة", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)])
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let messageTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textAlignment = .center
        return tv
    }()
    
    lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitleColor(UIColor.rgb(red:75, green:217, blue:100), for: .normal)
        button.setTitle("إتصل بالعميل", for: .normal)
        button.setImage(#imageLiteral(resourceName: "phone").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 7
        button.layer.borderColor = UIColor.rgb(red:75, green:217, blue:100).cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handelCallAction), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    @objc func handelCallAction(){
        guard let number = order?.phone.dropFirst() else { return }
        dialNumber(number: "+966\(number)")
        print("Trying to call \(String(describing: order?.phone))")
    }
    
    //MARK:- You must user lazy var to enable traget action
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red:75, green:217, blue:100)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("قبول", for: .normal)
        button.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handelAcceptOrderAction), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 7
        return button
    }()
    
    @objc func handelAcceptOrderAction() {
        guard let order = order else {return}
        guard let key = self.order?.key else {return}
        
        let timeStamp = ServerValue.timestamp()
        let dictionary: [String: Any] = ["timeStamp": timeStamp , "name": order.name, "orderStatutsAccepted": true, "phone": order.phone, "service": order.service]
        let values = [key: dictionary]
        // save to the completedOrdersTest tree
        Database.database().reference().child("completedOrdersTest").updateChildValues(values) { (err, snapshot) in
            if let err = err {
                print("Falied to save data", err)
                return
            }
            
            // remove order from the ordersTest tree
            Database.database().reference().child("ordersTest").child(key).setValue(nil) { (err, snapshot) in
                if let err = err {
                    print("Could not remove child id \(key) err: \(err)")
                }
                print("Successfully removed")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("رفض", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.setImage(#imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.cornerRadius = 7
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handelRejectionOrderAction), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    @objc func handelRejectionOrderAction(){
        guard let key = self.order?.key else {return}
        Database.database().reference().child("ordersTest").child(key).setValue(nil) { (err, snapshot) in
            if let err = err {
                print("Could not remove child id \(key) err: \(err)")
            }
            print("Successfully removed")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = order?.name
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        
        view.backgroundColor = .white
        setupViews()
        setupOrderRejectOrAccespView()
    }
    
    fileprivate func setupViews(){
        
        view.addSubview(orderDataLableOrderTitleLabel)
        orderDataLableOrderTitleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(orderDateLable)
        orderDateLable.anchor(top: orderDataLableOrderTitleLabel.bottomAnchor, left: orderDataLableOrderTitleLabel.leftAnchor, bottom: nil, right: orderDataLableOrderTitleLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(nameTitleLabel)
        nameTitleLabel.anchor(top: orderDateLable.bottomAnchor, left: orderDateLable.leftAnchor, bottom: nil, right: orderDateLable.rightAnchor, paddingTop: 3, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(nameLable)
        nameLable.anchor(top: nameTitleLabel.bottomAnchor, left: nameTitleLabel.leftAnchor, bottom: nil, right: nameTitleLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(serviceTitleLabel)
        serviceTitleLabel.anchor(top: nameLable.bottomAnchor, left: nameLable.leftAnchor, bottom: nil, right: nameLable.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        view.addSubview(servieLable)
        servieLable.anchor(top: serviceTitleLabel.bottomAnchor, left: serviceTitleLabel.leftAnchor, bottom: nil, right: serviceTitleLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
        
        guard let messageCount = order?.message.count else { return }
        print("messageCount:",messageCount)
        if messageCount > 0 {
            
            view.addSubview(messageTitleLabel)
            messageTitleLabel.anchor(top: servieLable.bottomAnchor, left: servieLable.leftAnchor, bottom: nil, right: servieLable.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 40)
            view.addSubview(messageTextView)
            messageTextView.anchor(top: messageTitleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 0, width: 0, height: 100)
        }
    }
    
    fileprivate func setupOrderRejectOrAccespView(){
        
        let stackView = UIStackView(arrangedSubviews: [callButton,acceptButton,rejectButton].reversed())
        stackView.isUserInteractionEnabled = true
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 40, paddingRight: 12, width: 0, height: 40)
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(topDividerView)
        topDividerView.anchor(top: nil, left: view.leftAnchor, bottom: stackView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12, paddingRight: 0, width: 0, height: 0.5)
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(bottomDividerView)
        bottomDividerView.anchor(top: view.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    fileprivate func dialNumber(number : String) {
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            print("The phone number is incoreect")
        }
    }
}
