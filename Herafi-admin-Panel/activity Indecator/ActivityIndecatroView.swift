//
//  ActivityIndecatroView.swift
//  Herafi-admin-Panel
//
//  Created by Mohsen Qaysi on 11/19/18.
//  Copyright © 2018 Mohsen Qaysi. All rights reserved.
//

import UIKit

class ActivityIndecatroView: UIView {
    
    @IBOutlet weak var indecator: UIActivityIndicatorView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
//    private func nibSetup() {
//        backgroundColor = .clear
//        let view = loadViewFromNib()
//        view.frame = bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.translatesAutoresizingMaskIntoConstraints = true
//
//        addSubview(view)
//    }
//
//    private func loadViewFromNib() -> UIView {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: String(type(of: self)), bundle: bundle)
//        let nibView = nib.instantiateWithOwner(self, options: nil).first as! UIView
//
//        return nibView
//    }
}
