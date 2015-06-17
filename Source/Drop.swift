//
//  Drop.swift
//  SwiftyDrop
//
//  Created by MORITANAOKI on 2015/06/18.
//  Copyright (c) 2015年 MORITANAOKI. All rights reserved.
//

import UIKit

class Drop: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}

extension Drop {
    class func down(title: String, subtitle: String?) {
        let drop = UINib(nibName: "Drop", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! Drop
        
        if let window = window() {
            window.addSubview(drop)
            
            let height = CGFloat(100.0)
            
            let heightConstraint = NSLayoutConstraint(
                item: drop,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1.0,
                constant: height
            )
            
            let constraints = ([.Top, .Left, .Right] as [NSLayoutAttribute]).map {
                return NSLayoutConstraint(
                    item: window,
                    attribute: $0,
                    relatedBy: .Equal,
                    toItem: drop,
                    attribute: $0,
                    multiplier: 1.0,
                    constant: 0.0
                )
            }
            
            drop.setTranslatesAutoresizingMaskIntoConstraints(false)
            drop.addConstraint(heightConstraint)
            window.addConstraints(constraints)
            drop.layoutIfNeeded()
        }
        
    }
    
    class func up() {
        
    }
}

extension Drop {
    private class func window() -> UIWindow? {
        return UIApplication.sharedApplication().keyWindow
    }
}