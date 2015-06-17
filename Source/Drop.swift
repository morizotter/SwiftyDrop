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
    
    var topConstraint: NSLayoutConstraint!
    let height = 100.0
    
    @IBAction func up(sender: AnyObject) {
        Drop.up(self)
    }
}

extension Drop {
    class func down(title: String, subtitle: String?) {
        let drop = UINib(nibName: "Drop", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! Drop
        
        if let window = window() {
            window.addSubview(drop)
            
            let heightConstraint = NSLayoutConstraint(
                item: drop,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1.0,
                constant: CGFloat(drop.height)
            )
            
            let sideConstraints = ([.Left, .Right] as [NSLayoutAttribute]).map {
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
            
            drop.topConstraint = NSLayoutConstraint(
                item: window,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: drop,
                attribute: .Top,
                multiplier: 1.0,
                constant: CGFloat(drop.height)
            )
            
            drop.setTranslatesAutoresizingMaskIntoConstraints(false)
            drop.addConstraint(heightConstraint)
            window.addConstraints(sideConstraints)
            window.addConstraint(drop.topConstraint)
            drop.layoutIfNeeded()
            
            drop.topConstraint.constant = 0.0
            UIView.animateWithDuration(
                NSTimeInterval(0.25),
                delay: NSTimeInterval(0.0),
                options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.CurveEaseOut,
                animations: { [unowned drop] () -> Void in
                    drop.layoutIfNeeded()
                }, completion: nil
            )
            
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(4.0) * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue(), { [weak drop] () -> Void in
                if let drop = drop { self.up(drop) }
            })
        }
    }
    
    class func up(drop: Drop) {
        drop.topConstraint.constant = CGFloat(drop.height)
        UIView.animateWithDuration(
            NSTimeInterval(0.25),
            delay: NSTimeInterval(0.0),
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
                drop.layoutIfNeeded()
            }, completion: nil)
    }
}

extension Drop {
    private class func window() -> UIWindow? {
        return UIApplication.sharedApplication().keyWindow
    }
}