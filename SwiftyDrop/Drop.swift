//
//  Drop.swift
//  SwiftyDrop
//
//  Created by MORITANAOKI on 2015/06/18.
//  Copyright (c) 2015年 MORITANAOKI. All rights reserved.
//

import UIKit

enum DropType {
    case LightBlur, Error, Warning, Success, Info, Default
    
    func backgroundColor() -> UIColor? {
        switch self {
        case LightBlur: return nil
        case Error: return UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 1.0)
        case Warning: return UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0)
        case Success: return UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 1.0)
        case Info: return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0)
        case Default: return UIColor(red: 41/255.0, green: 128/255.0, blue: 185/255.0, alpha: 1.0)
        }
    }
}

final class Drop: UIView {
    private var backgroundView: UIView!
    private var statusLabel: UILabel!
    
    private var topConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private let statusTopMargin: CGFloat = 8.0
    private let statusBottomMargin: CGFloat = 8.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1.0,
            constant: 100.0
        )
        self.addConstraint(heightConstraint)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func up() {
        Drop.up(self)
    }
    
    func updateHeight() {
        heightConstraint.constant = self.statusLabel.frame.size.height + Drop.statusBarHeight() + statusTopMargin + statusBottomMargin
        self.layoutIfNeeded()
    }
}

extension Drop {
    class func down(status: String) {
        down(.Default, status: status)
    }
    
    class func down(type: DropType, status: String) {
        self.upAll()
        if let window = window() {
            let drop = Drop(frame: CGRectZero)
            window.addSubview(drop)
            
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
                constant: drop.heightConstraint.constant
            )
            
            window.addConstraints(sideConstraints)
            window.addConstraint(drop.topConstraint)
            drop.setup(status, type: type)
            drop.updateHeight()
            
            drop.topConstraint.constant = 0.0
            UIView.animateWithDuration(
                NSTimeInterval(0.25),
                delay: NSTimeInterval(0.0),
                options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.CurveEaseOut,
                animations: { [weak drop] () -> Void in
                    if let drop = drop { drop.layoutIfNeeded() }
                }, completion: nil
            )
            
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(4.0) * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue(), { [weak drop] () -> Void in
                if let drop = drop { drop.up() }
            })
        }
    }
    
    class func up(drop: Drop) {
        drop.topConstraint.constant = drop.heightConstraint.constant
        UIView.animateWithDuration(
            NSTimeInterval(0.25),
            delay: NSTimeInterval(0.0),
            options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.CurveEaseOut,
            animations: { [weak drop] () -> Void in
                if let drop = drop {
                    drop.layoutIfNeeded()
                }
            }, completion: nil)
        // Need to remove drop
    }
    
    class func upAll() {
        if let window = Drop.window() {
            for view in window.subviews {
                if let drop = view as? Drop {
                    Drop.up(drop)
                }
            }
        }
    }
}

extension Drop {
    
    private func setup(status: String, type: DropType) {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if type == .LightBlur {
            let blurEffect = UIBlurEffect(style: .Light)
            
            let statusLabel = UILabel(frame: CGRectZero)
            statusLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            statusLabel.numberOfLines = 0
            statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            statusLabel.textAlignment = .Center
            statusLabel.text = status
            
            let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
            vibrancyEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            vibrancyEffectView.contentView.addSubview(statusLabel)
            
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            visualEffectView.contentView.addSubview(vibrancyEffectView)
            self.addSubview(visualEffectView)
            
            let visualEffectViewConstraints = ([.Top, .Right, .Bottom, .Left] as [NSLayoutAttribute]).map {
                return NSLayoutConstraint(
                    item: visualEffectView,
                    attribute: $0,
                    relatedBy: .Equal,
                    toItem: self,
                    attribute: $0,
                    multiplier: 1.0,
                    constant: 0.0
                )
            }
            self.addConstraints(visualEffectViewConstraints)
            self.backgroundView = visualEffectView
            
            let vibrancyLeft = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: visualEffectView.contentView,
                attribute: .LeftMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            let vibrancyRight = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: visualEffectView.contentView,
                attribute: .RightMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            let vibrancyTop = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: visualEffectView.contentView,
                attribute: .Top,
                multiplier: 1.0,
                constant: Drop.statusBarHeight() + statusTopMargin
            )
            let vibrancyBottom = NSLayoutConstraint(
                item: vibrancyEffectView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: visualEffectView.contentView,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0
            )
            visualEffectView.contentView.addConstraints([vibrancyTop, vibrancyRight, vibrancyBottom, vibrancyLeft])
            
            let statusLeft = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .Left,
                multiplier: 1.0,
                constant: 0.0
            )
            let statusRight = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .Right,
                multiplier: 1.0,
                constant: 0.0
            )
            let statusTop = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .Top,
                multiplier: 1.0,
                constant: 0.0
            )
            vibrancyEffectView.contentView.addConstraints([statusTop, statusRight, statusLeft])
            self.statusLabel = statusLabel
        } else {
            let backgroundView = UIView(frame: CGRectZero)
            backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
            backgroundView.alpha = 0.9
            backgroundView.backgroundColor = type.backgroundColor()
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
            self.backgroundView = backgroundView
            
            let statusLabel = UILabel(frame: CGRectZero)
            statusLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            statusLabel.numberOfLines = 0
            statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            statusLabel.textAlignment = .Center
            statusLabel.textColor = UIColor.whiteColor()
            statusLabel.text = status
            self.addSubview(statusLabel)
            
            let statusLeft = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: self,
                attribute: .LeftMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            
            let statusRight = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: self,
                attribute: .RightMargin,
                multiplier: 1.0,
                constant: 0.0
            )
            
            let statusTop = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1.0,
                constant: Drop.statusBarHeight() + statusTopMargin
            )
            
            self.addConstraints([statusLeft, statusRight, statusTop])
            self.statusLabel = statusLabel
        }
        
        self.layoutIfNeeded()
        
        self.userInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "up:"))
    }
}

extension Drop {
    private class func window() -> UIWindow? {
        return UIApplication.sharedApplication().keyWindow
    }
    
    private class func statusBarHeight() -> CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.size.height
    }
}
