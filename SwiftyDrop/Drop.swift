//
//  Drop.swift
//  SwiftyDrop
//
//  Created by MORITANAOKI on 2015/06/18.
//  Copyright (c) 2015年 MORITANAOKI. All rights reserved.
//

import UIKit

class Drop: UIView {
    
    var topConstraint: NSLayoutConstraint!
    let height = 100.0
    
    func up(sender: AnyObject) {
        Drop.up(self)
    }
}

extension Drop {
    class func down(status: String) {
        if let window = window() {
            let drop = Drop(frame: CGRectZero)
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
            
            drop.addConstraint(heightConstraint)
            window.addConstraints(sideConstraints)
            window.addConstraint(drop.topConstraint)
            drop.setup(status)
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
    
    private func setup(status: String) {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let backgroundView = UIImageView(frame: CGRectZero)
        backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
        backgroundView.backgroundColor = UIColor.redColor()
        self.addSubview(backgroundView)

        let backgroundConstraints = ([.Top, .Right, .Bottom, .Left] as [NSLayoutAttribute]).map {
            return NSLayoutConstraint(
                item: backgroundView,
                attribute: $0,
                relatedBy: .Equal,
                toItem: self,
                attribute: $0,
                multiplier: 1.0,
                constant: 0.0
            )
        }
        self.addConstraints(backgroundConstraints)
        
        let statusLabel = UILabel(frame: CGRectZero)
        statusLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        statusLabel.textAlignment = .Center
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.text = status
        self.addSubview(statusLabel)
        
        let sideConstraints = ([.LeftMargin, .RightMargin] as [NSLayoutAttribute]).map {
            return NSLayoutConstraint(
                item: statusLabel,
                attribute: $0,
                relatedBy: .Equal,
                toItem: self,
                attribute: $0,
                multiplier: 1.0,
                constant: 10.0
            )
        }
        
        let topConstraint = NSLayoutConstraint(
            item: statusLabel,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Top,
            multiplier: 1.0,
            constant: 20.0
        )

        self.addConstraints(sideConstraints)
        self.addConstraint(topConstraint)
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "up:"))
    }
}