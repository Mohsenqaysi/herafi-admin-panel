//
// HistoryCollectionCell.swift
//  Herafi-admin-Panel
//
//  Created by Mohsen Qaysi on 11/17/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit

class HistoryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var orderStatusButton: UIButton!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var datelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        messageLabel.isEditable = false
    }
    @IBAction func CallCustomer(_ sender: UIButton) {
        print("tring to call customer...")
    }
}
