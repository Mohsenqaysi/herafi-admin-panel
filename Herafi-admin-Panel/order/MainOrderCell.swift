//
//  MainOrderCell.swift
//  HerafiAdmin
//
//  Created by Mohsen Qaysi on 11/9/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit

class MainOrderCell: UICollectionViewCell {
    
    var order: Order? {
        didSet{
            guard let date = order?.dateNow else {return}
            print("MainOrderCell timeStamp:", date)
            guard let convertedDate = String.convertDate(currentTimeInMiliseconds: date) else {return}
            dataLableText.text = convertedDate
            
            switch order?.service {
            case "خدمات الكهرباء":
                cellIcon.image = #imageLiteral(resourceName: "electrical")
            case "خدمات السباكة":
                cellIcon.image = #imageLiteral(resourceName: "water-pipe")
            case "خدمات التكييف":
                cellIcon.image = #imageLiteral(resourceName: "air-conditioner")
            case "خدمات الكمبيوتر":
                cellIcon.image = #imageLiteral(resourceName: "laptop-outline")
            default:
                break
            }
        }
    }
    
    var orderCompleted: Order? {
        didSet{
            guard let name = orderCompleted?.name else {return}
            dataTitleLable.text = name
            
            guard let date = orderCompleted?.dateNow else {return}
            print("MainOrderCell timeStamp:", date)
            guard let convertedDate = String.convertDate(currentTimeInMiliseconds: date) else {return}
            dataLableText.text = convertedDate
            
            guard let service = orderCompleted?.service else {
                print("Failed to load icon")
                return
            }
            
            switch service {
            case "خدمات الكهرباء":
                cellIcon.image = #imageLiteral(resourceName: "electrical")
            case "خدمات السباكة":
                cellIcon.image = #imageLiteral(resourceName: "water-pipe")
            case "خدمات التكييف":
                cellIcon.image = #imageLiteral(resourceName: "air-conditioner")
            case "خدمات الكمبيوتر":
                cellIcon.image = #imageLiteral(resourceName: "laptop-outline")
            default:
                break
            }
        }
    }
    
    let cellIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "electrical")
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = UIColor(white: 0, alpha: 0.1)
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let newOrderIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "new")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let dataTitleLable: UILabel = {
        let label = UILabel()
        label.text = "تاريخ الطلب"
        label.textAlignment = .right
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let dataLableText: UILabel = {
        let label = UILabel()
        label.text = "تاريخ الطلب"
        label.numberOfLines = 2
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.isUserInteractionEnabled = true
        layer.cornerRadius = 7
        layer.masksToBounds = true
        
        setupViews()
    }
    
    fileprivate func setupViews(){
        addSubview(cellIcon)
        cellIcon.anchor(top: topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 4, width: 50, height: 0)
        cellIcon.layer.cornerRadius = (cellIcon.frame.width - 8) / 2
        cellIcon.layer.masksToBounds = true
        cellIcon.layer.borderColor = UIColor(white: 0, alpha: 0.01).cgColor
        cellIcon.layer.borderWidth = 0.5
        
        addSubview(dataTitleLable)
        dataTitleLable.anchor(top: cellIcon.topAnchor, left: nil, bottom: nil, right: cellIcon.leftAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 4, width: 0, height: 30)
        
        addSubview(dataLableText)
        dataLableText.anchor(top: nil, left: nil, bottom: bottomAnchor, right: cellIcon.leftAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 2, paddingRight: 4, width: 200, height: 40)
        
        addSubview(newOrderIcon)
        newOrderIcon.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 2, paddingLeft: 2, paddingBottom: 2, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
