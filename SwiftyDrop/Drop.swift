//
//  Drop.swift
//  SwiftyDrop
//
//  Created by MORITANAOKI on 2015/06/18.
//

import UIKit

public enum DropState {
    case Default, Info, Success, Warning, Error
    
    private func backgroundColor() -> UIColor? {
        switch self {
        case Default: return UIColor(red: 41/255.0, green: 128/255.0, blue: 185/255.0, alpha: 1.0)
        case Info: return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1.0)
        case Success: return UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 1.0)
        case Warning: return UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 1.0)
        case Error: return UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 1.0)
        }
    }
}

public enum DropBlur {
    case Light, ExtraLight, Dark
    
    private func blurEffect() -> UIBlurEffect {
        switch self {
        case .Light: return UIBlurEffect(style: .Light)
        case .ExtraLight: return UIBlurEffect(style: .ExtraLight)
        case .Dark: return UIBlurEffect(style: .Dark)
        }
    }
}

public final class Drop: UIView {
    private var backgroundView: UIView!
    private var statusLabel: UILabel!
    private var topConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private let statusTopMargin: CGFloat = 8.0
    private let statusBottomMargin: CGFloat = 8.0
    private var upTimer: NSTimer?
    private var startTop: CGFloat?
    
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
        scheduleUpTimer(4.0)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil) { [weak self] notification in
            if let s = self {
                s.stopUpTimer()
                s.removeFromSuperview()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIDeviceOrientationDidChangeNotification, object: nil, queue: nil) { [weak self] notification in
            if let s = self {
                s.updateHeight()
            }
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        stopUpTimer()
    }
    
    func up() {
        scheduleUpTimer(0.0)
    }
    
    func upFromTimer(timer: NSTimer) {
        if let interval = timer.userInfo as? Double {
            Drop.up(self, interval: interval)
        }
    }
    
    private func scheduleUpTimer(after: Double) {
        scheduleUpTimer(after, interval: 0.25)
    }
    
    private func scheduleUpTimer(after: Double, interval: Double) {
        stopUpTimer()
        upTimer = NSTimer.scheduledTimerWithTimeInterval(after, target: self, selector: "upFromTimer:", userInfo: interval, repeats: false)
    }
    
    private func stopUpTimer() {
        upTimer?.invalidate()
        upTimer = nil
    }
    
    private func updateHeight() {
        heightConstraint.constant = self.statusLabel.frame.size.height + Drop.statusBarHeight() + statusTopMargin + statusBottomMargin
        self.layoutIfNeeded()
    }
}

extension Drop {
    public class func down(status: String) {
        down(status, state: .Default)
    }
    
    public class func down(status: String, state: DropState) {
        down(status, state: state, blur: nil)
    }
    
    public class func down(status: String, blur: DropBlur) {
        down(status, state: nil, blur: blur)
    }
    
    private class func down(status: String, state: DropState?, blur: DropBlur?) {
        self.upAll()
        let drop = Drop(frame: CGRectZero)
        Drop.window().addSubview(drop)
        
        let sideConstraints = ([.Left, .Right] as [NSLayoutAttribute]).map {
            return NSLayoutConstraint(
                item: drop,
                attribute: $0,
                relatedBy: .Equal,
                toItem: Drop.window(),
                attribute: $0,
                multiplier: 1.0,
                constant: 0.0
            )
        }
        
        drop.topConstraint = NSLayoutConstraint(
            item: drop,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: Drop.window(),
            attribute: .Top,
            multiplier: 1.0,
            constant: -drop.heightConstraint.constant
        )
        
        Drop.window().addConstraints(sideConstraints)
        Drop.window().addConstraint(drop.topConstraint)
        drop.setup(status, state: state, blur: blur)
        drop.updateHeight()
        
        drop.topConstraint.constant = 0.0
        UIView.animateWithDuration(
            NSTimeInterval(0.25),
            delay: NSTimeInterval(0.0),
            options: .AllowUserInteraction | .CurveEaseOut,
            animations: { [weak drop] () -> Void in
                if let drop = drop { drop.layoutIfNeeded() }
            }, completion: nil
        )
    }
    
    private class func up(drop: Drop, interval: NSTimeInterval) {
        drop.topConstraint.constant = -drop.heightConstraint.constant
        UIView.animateWithDuration(
            interval,
            delay: NSTimeInterval(0.0),
            options: .AllowUserInteraction | .CurveEaseIn,
            animations: { [weak drop] () -> Void in
                if let drop = drop {
                    drop.layoutIfNeeded()
                }
            }) { [weak drop] finished -> Void in
                if let drop = drop { drop.removeFromSuperview() }
        }
    }
    
    public class func upAll() {
        for view in Drop.window().subviews {
            if let drop = view as? Drop {
                drop.up()
            }
        }
    }
}

extension Drop {
    private func setup(status: String, state: DropState?, blur: DropBlur?) {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        if let blur = blur {
            let blurEffect = blur.blurEffect()
            
            // Visual Effect View
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.addSubview(visualEffectView)
            let visualEffectViewConstraints = ([.Right, .Bottom, .Left] as [NSLayoutAttribute]).map {
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
            let topConstraint = NSLayoutConstraint(
                item: visualEffectView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1.0,
                constant: -UIScreen.mainScreen().bounds.height
            )
            
            self.addConstraints(visualEffectViewConstraints)
            self.addConstraint(topConstraint)
            self.backgroundView = visualEffectView
            
            // Vibrancy Effect View
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
            vibrancyEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            visualEffectView.contentView.addSubview(vibrancyEffectView)
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
                constant: 0.0
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
            
            // STATUS LABEL
            let statusLabel = createStatusLabel(status, isVisualEffect: true)
            vibrancyEffectView.contentView.addSubview(statusLabel)
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
            let statusBottom = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: vibrancyEffectView.contentView,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: -statusBottomMargin
            )
            vibrancyEffectView.contentView.addConstraints([statusRight, statusLeft, statusBottom])
            self.statusLabel = statusLabel
        }
        
        if let state = state {
            // Background View
            let backgroundView = UIView(frame: CGRectZero)
            backgroundView.setTranslatesAutoresizingMaskIntoConstraints(false)
            backgroundView.alpha = 0.9
            backgroundView.backgroundColor = state.backgroundColor()
            self.addSubview(backgroundView)
            let backgroundConstraints = ([.Right, .Bottom, .Left] as [NSLayoutAttribute]).map {
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
            
            let topConstraint = NSLayoutConstraint(
                item: backgroundView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Top,
                multiplier: 1.0,
                constant: -UIScreen.mainScreen().bounds.height
            )
            
            self.addConstraints(backgroundConstraints)
            self.addConstraint(topConstraint)
            self.backgroundView = backgroundView
            
            // Status Label
            let statusLabel = createStatusLabel(status, isVisualEffect: false)
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
            let statusBottom = NSLayoutConstraint(
                item: statusLabel,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: -statusBottomMargin
            )
            self.addConstraints([statusLeft, statusRight, statusBottom])
            self.statusLabel = statusLabel
        }
        
        self.layoutIfNeeded()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "up:")
        self.addGestureRecognizer(tapRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
        self.addGestureRecognizer(panRecognizer)
    }
    
    private func createStatusLabel(status: String, isVisualEffect: Bool) -> UILabel {
        let label = UILabel(frame: CGRectZero)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.numberOfLines = 0
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.textAlignment = .Center
        label.text = status
        if !isVisualEffect { label.textColor = UIColor.whiteColor() }
        return label
    }
}

extension Drop {
    func up(sender: AnyObject) {
        self.up()
    }
    
    func pan(sender: AnyObject) {
        let pan = sender as! UIPanGestureRecognizer
        switch pan.state {
        case .Began:
            stopUpTimer()
            startTop = topConstraint.constant
        case .Changed:
            let location = pan.locationInView(Drop.window())
            let translation = pan.translationInView(Drop.window())
            let top = startTop! + translation.y
            if top > 0.0 {
                topConstraint.constant = top * 0.2
            } else {
                topConstraint.constant = top
            }
        case .Ended:
            startTop = nil
            if topConstraint.constant < 0.0 {
                scheduleUpTimer(0.0, interval: 0.1)
            } else {
                scheduleUpTimer(4.0)
                topConstraint.constant = 0.0
                UIView.animateWithDuration(
                    NSTimeInterval(0.1),
                    delay: NSTimeInterval(0.0),
                    options: .AllowUserInteraction | .CurveEaseOut,
                    animations: { [weak self] () -> Void in
                        if let s = self { s.layoutIfNeeded() }
                    }, completion: nil
                )
            }
        case .Failed, .Cancelled:
            startTop = nil
            scheduleUpTimer(2.0)
        case .Possible: break
        }
    }
}

extension Drop {
    private class func window() -> UIWindow {
        return UIApplication.sharedApplication().keyWindow!
    }
    
    private class func statusBarHeight() -> CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.size.height
    }
}
