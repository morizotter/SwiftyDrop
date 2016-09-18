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
    case `default`, info, success, warning, error, color(UIColor), blur(UIBlurEffectStyle)
    
    public var backgroundColor: UIColor? {
        switch self {
        case .info: return UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 0.9)
        case .success: return UIColor(red: 39/255.0, green: 174/255.0, blue: 96/255.0, alpha: 0.9)
        case .warning: return UIColor(red: 241/255.0, green: 196/255.0, blue: 15/255.0, alpha: 0.9)
        case .error: return UIColor(red: 192/255.0, green: 57/255.0, blue: 43/255.0, alpha: 0.9)
        case .color(let color): return color
        case .blur: return nil
        default: return UIColor(red: 41/255.0, green: 128/255.0, blue: 185/255.0, alpha: 0.9)
        }
    }
    
    public var font: UIFont? {
        switch self {
        default: return UIFont.systemFont(ofSize: 17.0)
        }
    }
    
    public var textColor: UIColor? {
        switch self {
        default: return .white
        }
    }
    
    public var blurEffect: UIBlurEffect? {
        switch self {
        case .blur(let style): return UIBlurEffect(style: style)
        default: return nil
        }
    }
}

public typealias DropAction = () -> Void

public final class Drop: UIView {
    static let PRESET_DURATION: TimeInterval = 4.0
    
    fileprivate var statusLabel: UILabel!
    fileprivate let statusTopMargin: CGFloat = 10.0
    fileprivate let statusBottomMargin: CGFloat = 10.0
    fileprivate var minimumHeight: CGFloat { return UIApplication.shared.statusBarFrame.height + 44.0 }
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var heightConstraint: NSLayoutConstraint?
    
    fileprivate var duration: TimeInterval = Drop.PRESET_DURATION
    
    fileprivate var upTimer: Timer?
    fileprivate var startTop: CGFloat?

    fileprivate var action: DropAction?

    convenience init(duration: Double) {
        self.init(frame: CGRect.zero)
        self.duration = duration
        
        scheduleUpTimer(duration)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Drop.deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        stopUpTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationDidEnterBackground(_ notification: Notification) {
        stopUpTimer()
        removeFromSuperview()
    }
    
    func deviceOrientationDidChange(_ notification: Notification) {
        updateHeight()
    }
    
    func up() {
        scheduleUpTimer(0.0)
    }
    
    func upFromTimer(_ timer: Timer) {
        if let interval = timer.userInfo as? Double {
            Drop.up(self, interval: interval)
        }
    }
    
    fileprivate func scheduleUpTimer(_ after: Double) {
        scheduleUpTimer(after, interval: 0.25)
    }
    
    fileprivate func scheduleUpTimer(_ after: Double, interval: Double) {
        stopUpTimer()
        upTimer = Timer.scheduledTimer(timeInterval: after, target: self, selector: #selector(self.upFromTimer(_:)), userInfo: interval, repeats: false)
    }
    
    fileprivate func stopUpTimer() {
        upTimer?.invalidate()
        upTimer = nil
    }
    
    fileprivate func updateHeight() {
        var height: CGFloat = 0.0
        height += UIApplication.shared.statusBarFrame.height
        height += statusTopMargin
        height += statusLabel.frame.size.height
        height += statusBottomMargin
        heightConstraint?.constant = height > minimumHeight ? height : minimumHeight
        self.layoutIfNeeded()
    }
}

extension Drop {
    public class func down(_ status: String, state: DropState = .default, duration: Double = Drop.PRESET_DURATION, action: DropAction? = nil) {
        show(status, state: state, duration: duration, action: action)
    }

    public class func down<T: DropStatable>(_ status: String, state: T, duration: Double = Drop.PRESET_DURATION, action: DropAction? = nil) {
        show(status, state: state, duration: duration, action: action)
    }

    fileprivate class func show(_ status: String, state: DropStatable, duration: Double, action: DropAction?) {
        self.upAll()
        let drop = Drop(duration: duration)
        UIApplication.shared.keyWindow?.addSubview(drop)
        guard let window = drop.window else { return }

        let heightConstraint = NSLayoutConstraint(item: drop, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 100.0)
        drop.addConstraint(heightConstraint)
        drop.heightConstraint = heightConstraint

        let topConstraint = NSLayoutConstraint(item: drop, attribute: .top, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 1.0, constant: -heightConstraint.constant)
        drop.topConstraint = topConstraint

        window.addConstraints(
            [
                topConstraint,
                NSLayoutConstraint(item: drop, attribute: .left, relatedBy: .equal, toItem: window, attribute: .left, multiplier: 1.0,constant: 0.0),
                NSLayoutConstraint(item: drop, attribute: .right, relatedBy: .equal, toItem: window, attribute: .right, multiplier: 1.0,constant: 0.0)
            ]
        )

        drop.setup(status, state: state)
        drop.action = action
        drop.updateHeight()
        
        guard let superview = drop.superview else { return }
        superview.layoutIfNeeded()
        
        topConstraint.constant = 0.0
        UIView.animate(
            withDuration: TimeInterval(0.25),
            delay: TimeInterval(0.0),
            options: [.allowUserInteraction, .curveEaseOut],
            animations: { _ in
                superview.layoutIfNeeded()
            }, completion: nil
        )
    }
    
    fileprivate class func up(_ drop: Drop, interval: TimeInterval) {
        guard let heightConstant = drop.heightConstraint?.constant else { return }
        drop.topConstraint?.constant = -heightConstant
        
        guard let superview = drop.superview else { return }
        
        UIView.animate(
            withDuration: interval,
            delay: TimeInterval(0.0),
            options: [.allowUserInteraction, .curveEaseIn],
            animations: { _ in
                superview.layoutIfNeeded()
            }) { [weak drop] finished -> Void in
                if let drop = drop { drop.removeFromSuperview() }
        }
    }
    
    public class func upAll() {
        guard let window = UIApplication.shared.keyWindow else { return }
        for view in window.subviews {
            if let drop = view as? Drop {
                drop.up()
            }
        }
    }
}

extension Drop {
    fileprivate func setup(_ status: String, state: DropStatable) {
        self.translatesAutoresizingMaskIntoConstraints = false
        var labelParentView: UIView = self
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = state.backgroundColor
        addSubview(backgroundView)
        addConstraints(
            [
                NSLayoutConstraint(item: backgroundView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -UIScreen.main.bounds.height),
                NSLayoutConstraint(item: backgroundView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            ]
        )
        
        if let blurEffect = state.blurEffect {
            let visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(visualEffectView)
            addConstraints(
                [
                    NSLayoutConstraint(item: visualEffectView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -UIScreen.main.bounds.height),
                    NSLayoutConstraint(item: visualEffectView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: visualEffectView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                ]
            )
            
            let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
            vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
            visualEffectView.contentView.addSubview(vibrancyEffectView)
            visualEffectView.contentView.addConstraints(
                [
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .left, relatedBy: .equal, toItem: visualEffectView.contentView, attribute: .leftMargin, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .top, relatedBy: .equal, toItem: visualEffectView.contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .right, relatedBy: .equal, toItem: visualEffectView.contentView, attribute: .rightMargin, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: vibrancyEffectView, attribute: .bottom, relatedBy: .equal, toItem: visualEffectView.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0
                    )
                ]
            )
            
            labelParentView = vibrancyEffectView.contentView
        }
        
        let statusLabel = UILabel(frame: CGRect.zero)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.numberOfLines = 0
        statusLabel.font = state.font ?? UIFont.systemFont(ofSize: 17.0)
        statusLabel.textAlignment = .center
        statusLabel.text = status
        statusLabel.textColor = state.textColor ?? .white
        labelParentView.addSubview(statusLabel)
        labelParentView.addConstraints(
            [
                NSLayoutConstraint(item: statusLabel, attribute: .left, relatedBy: .equal, toItem: labelParentView, attribute: .leftMargin, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: statusLabel, attribute: .right, relatedBy: .equal, toItem: labelParentView, attribute: .rightMargin, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: statusLabel, attribute: .bottom, relatedBy: .equal, toItem: labelParentView, attribute: .bottom, multiplier: 1.0, constant: -statusBottomMargin)
            ]
        )
        self.statusLabel = statusLabel
        
        self.layoutIfNeeded()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.up(_:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:))))
    }
}

extension Drop {
    func up(_ sender: AnyObject) {
        action?()
        self.up()
    }
    
    func pan(_ sender: AnyObject) {
        let pan = sender as! UIPanGestureRecognizer
        switch pan.state {
        case .began:
            stopUpTimer()
            guard let topConstant = topConstraint?.constant else { return }
            startTop = topConstant
        case .changed:
            guard let window = window else { break }
            let translation = pan.translation(in: window)
            let top = startTop! + translation.y
            if top > 0.0 {
                topConstraint?.constant = top * 0.2
            } else {
                topConstraint?.constant = top
            }
        case .ended:
            startTop = nil
            guard let topConstraint = topConstraint else { return }
            if topConstraint.constant < 0.0 {
                scheduleUpTimer(0.0, interval: 0.1)
            } else {
                scheduleUpTimer(duration)
                guard let superview = superview else { return }
                topConstraint.constant = 0.0
                UIView.animate(
                    withDuration: TimeInterval(0.1),
                    delay: TimeInterval(0.0),
                    options: [.allowUserInteraction, .curveEaseOut],
                    animations: { _ in
                        superview.layoutIfNeeded()
                    }, completion: nil
                )
            }
        case .failed, .cancelled:
            startTop = nil
            scheduleUpTimer(2.0)
        case .possible: break
        }
    }
}
