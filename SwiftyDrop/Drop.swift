//
//  Drop.swift
//  SwiftyDrop
//
//  Created by MORITANAOKI on 2015/06/18.
//

import UIKit

public protocol DropStatable {
    var backgroundColor: UIColor? { get }
    var blurEffect: UIBlurEffect? { get }
    var font: UIFont? { get }
    var textColor: UIColor? { get }
}

public enum DropState: DropStatable {
    case Default, Info, Success, Warning, Error, Color(UIColor), Blur(UIBlurEffectStyle)
    
    public var backgroundColor: UIColor? {
        switch self {
        case Default: return UIColor(red: 41/255.0, green: 128/255.0, blue: 185/255.0, alpha: 0.9)
        case Info: return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.9)
        case Success: return UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 0.9)
        case Warning: return UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 0.9)
        case Error: return UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 0.9)
        case Color(let color): return color
        case Blur: return nil
        }
    }
    
    public var font: UIFont? {
        switch self {
        default: return UIFont.systemFontOfSize(17.0)
        }
    }
    
    public var textColor: UIColor? {
        switch self {
        default: return .whiteColor()
        }
    }
    
    public var blurEffect: UIBlurEffect? {
        switch self {
        case .Blur(let style): return UIBlurEffect(style: style)
        default: return nil
        }
    }
}

public typealias DropAction = () -> Void

public final class Drop: UIView {
    static let PRESET_DURATION: NSTimeInterval = 4.0
    
    private var statusLabel: UILabel!
    private let statusTopMargin: CGFloat = 10.0
    private let statusBottomMargin: CGFloat = 10.0
    private var minimumHeight: CGFloat { return UIApplication.sharedApplication().statusBarFrame.height + 44.0 }
    private var topConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    
    private var duration: NSTimeInterval = Drop.PRESET_DURATION
    
    private var upTimer: NSTimer?
    private var startTop: CGFloat?

    private var action: DropAction?

    convenience init(duration: Double) {
        self.init(frame: CGRect.zero)
        self.duration = duration
        
        scheduleUpTimer(duration)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        stopUpTimer()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        stopUpTimer()
        removeFromSuperview()
    }
    
    func deviceOrientationDidChange(notification: NSNotification) {
        updateHeight()
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
        var height: CGFloat = 0.0
        height += UIApplication.sharedApplication().statusBarFrame.height
        height += statusTopMargin
        height += statusLabel.frame.size.height
        height += statusBottomMargin
        heightConstraint?.constant = height > minimumHeight ? height : minimumHeight
        self.layoutIfNeeded()
    }
}

extension Drop {
    public class func down(status: String, state: DropState = .Default, duration: Double = Drop.PRESET_DURATION, action: DropAction? = nil) {
        show(status, state: state, duration: duration, action: action)
    }

    public class func down<T: DropStatable>(status: String, state: T, duration: Double = Drop.PRESET_DURATION, action: DropAction? = nil) {
        show(status, state: state, duration: duration, action: action)
    }

    private class func show(status: String, state: DropStatable, duration: Double, action: DropAction?) {
        self.upAll()
        let drop = Drop(duration: duration)
        UIApplication.sharedApplication().keyWindow?.addSubview(drop)
        guard let window = drop.window else { return }

        let heightConstraint = NSLayoutConstraint(item: drop, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 100.0)
        drop.addConstraint(heightConstraint)
        drop.heightConstraint = heightConstraint

        let topConstraint = NSLayoutConstraint(item: drop, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1.0, constant: -heightConstraint.constant)
        drop.topConstraint = topConstraint

        window.addConstraints(
            [
                topConstraint,
                NSLayoutConstraint(item: drop, attribute: .Left, relatedBy: .Equal, toItem: window, attribute: .Left, multiplier: 1.0,constant: 0.0),
                NSLayoutConstraint(item: drop, attribute: .Right, relatedBy: .Equal, toItem: window, attribute: .Right, multiplier: 1.0,constant: 0.0)
            ]
        )

        drop.setup(status, state: state)
        drop.action = action
        drop.updateHeight()

        topConstraint.constant = 0.0
        UIView.animateWithDuration(
            NSTimeInterval(0.25),
            delay: NSTimeInterval(0.0),
            options: [.AllowUserInteraction, .CurveEaseOut],
            animations: { [weak drop] () -> Void in
                if let drop = drop { drop.layoutIfNeeded() }
            }, completion: nil
        )
    }
    
    private class func up(drop: Drop, interval: NSTimeInterval) {
        guard let heightConstant = drop.heightConstraint?.constant else { return }
        drop.topConstraint?.constant = -heightConstant
        UIView.animateWithDuration(
            interval,
            delay: NSTimeInterval(0.0),
            options: [.AllowUserInteraction, .CurveEaseIn],
            animations: { [weak drop] () -> Void in
                if let drop = drop {
                    drop.layoutIfNeeded()
                }
            }) { [weak drop] finished -> Void in
                if let drop = drop { drop.removeFromSuperview() }
        }
    }
    
    public class func upAll() {
        guard let window = UIApplication.sharedApplication().keyWindow else { return }
        for view in window.subviews {
            if let drop = view as? Drop {
                drop.up()
            }
        }
    }
}

extension Drop {
    private func setup(status: String, state: DropStatable) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var labelParentView: UIView = self
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = state.backgroundColor
        addSubview(backgroundView)
        addConstraints(
            [
                NSLayoutConstraint(item: backgroundView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: -UIScreen.mainScreen().bounds.height),
                NSLayoutConstraint(item: backgroundView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
            ]
        )
        
        if let blurEffect = state.blurEffect {
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(visualEffectView)
            addConstraints(
                [
                    NSLayoutConstraint(item: visualEffectView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: visualEffectView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: -UIScreen.mainScreen().bounds.height),
                    NSLayoutConstraint(item: visualEffectView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: visualEffectView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                ]
            )
            
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
            vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.contentView.addSubview(vibrancyEffectView)
            visualEffectView.contentView.addConstraints(
                [
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .Left, relatedBy: .Equal, toItem: visualEffectView.contentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .Top, relatedBy: .Equal, toItem: visualEffectView.contentView, attribute: .Top, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .Right, relatedBy: .Equal, toItem: visualEffectView.contentView, attribute: .RightMargin, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .Bottom, relatedBy: .Equal, toItem: visualEffectView.contentView, attribute: .Bottom, multiplier: 1.0, constant: 0.0
                    )
                ]
            )
            
            labelParentView = vibrancyEffectView.contentView
        }
        
        let statusLabel = UILabel(frame: CGRect.zero)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 0
        statusLabel.font = state.font ?? UIFont.systemFontOfSize(17.0)
        statusLabel.textAlignment = .Center
        statusLabel.text = status
        statusLabel.textColor = state.textColor ?? .whiteColor()
        labelParentView.addSubview(statusLabel)
        labelParentView.addConstraints(
            [
                NSLayoutConstraint(item: statusLabel, attribute: .Left, relatedBy: .Equal, toItem: labelParentView, attribute: .LeftMargin, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: statusLabel, attribute: .Right, relatedBy: .Equal, toItem: labelParentView, attribute: .RightMargin, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: statusLabel, attribute: .Bottom, relatedBy: .Equal, toItem: labelParentView, attribute: .Bottom, multiplier: 1.0, constant: -statusBottomMargin)
            ]
        )
        self.statusLabel = statusLabel
        
        self.layoutIfNeeded()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "up:"))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pan:"))
    }
}

extension Drop {
    func up(sender: AnyObject) {
        action?()
        self.up()
    }
    
    func pan(sender: AnyObject) {
        let pan = sender as! UIPanGestureRecognizer
        switch pan.state {
        case .Began:
            stopUpTimer()
            guard let topConstant = topConstraint?.constant else { return }
            startTop = topConstant
        case .Changed:
            guard let window = window else { break }
            let translation = pan.translationInView(window)
            let top = startTop! + translation.y
            if top > 0.0 {
                topConstraint?.constant = top * 0.2
            } else {
                topConstraint?.constant = top
            }
        case .Ended:
            startTop = nil
            if topConstraint?.constant < 0.0 {
                scheduleUpTimer(0.0, interval: 0.1)
            } else {
                scheduleUpTimer(duration)
                topConstraint?.constant = 0.0
                UIView.animateWithDuration(
                    NSTimeInterval(0.1),
                    delay: NSTimeInterval(0.0),
                    options: [.AllowUserInteraction, .CurveEaseOut],
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
