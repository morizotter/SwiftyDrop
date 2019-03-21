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
    var textAlignment: NSTextAlignment? { get }
}

public enum DropState: DropStatable {
    
    case `default`, info, success, warning, error, color(UIColor), blur(UIBlurEffect.Style)
    
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
    
    public var textAlignment: NSTextAlignment? {
        switch self {
        default:
            return .center
        }
    }
}

public typealias DropAction = () -> Void

public final class Drop: UIView {
    static let PRESET_DURATION: TimeInterval = 4.0
    
    fileprivate var statusLabel: UILabel!
    fileprivate let statusTopMargin: CGFloat = 10.0
    fileprivate let statusBottomMargin: CGFloat = 10.0
    fileprivate var minimumHeight: CGFloat { return UIApplication.shared.statusBarFrame.height }
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var heightConstraint: NSLayoutConstraint?
    
    fileprivate var duration: TimeInterval = Drop.PRESET_DURATION
    fileprivate var deviceNotch: Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //iPhone 5 or 5S or 5C
                return false
            case 1334:
                //iPhone 6/6S/7/8
                return false
            case 1920, 2208:
                //iPhone 6+/6S+/7+/8+
                return false
            case 2436:
                //iPhone X, XS
                return true
            case 2688:
                //iPhone XS Max
                return true
            case 1792:
                //iPhone XR
                return true
            default:
                return true
            }
        } else {
            return false
        }
    }
    
    fileprivate var upTimer: Timer?
    fileprivate var startTop: CGFloat?

    fileprivate var action: DropAction?

    convenience init(duration: Double) {
        self.init(frame: CGRect.zero)
        self.duration = duration
        
        scheduleUpTimer(duration)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        stopUpTimer()
        removeFromSuperview()
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification) {
        layoutIfNeeded()
    }
    
    func up() {
        scheduleUpTimer(0.0)
    }
    
    @objc func upFromTimer(_ timer: Timer) {
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
    
    public enum DropHeight {
        case statusBar
        case navigationBar
        case standard
    }
    
    fileprivate func getDeviceNotchHeight() -> CGFloat {
        if deviceNotch == true {
            return 30
        } else {
            return 0
        }
    }
    
    fileprivate func getHeight(dropHeight: DropHeight) -> CGFloat {
        var height: CGFloat = 0.0
        height += getDeviceNotchHeight()
        switch dropHeight {
        case .statusBar:
            height += 24.0
        case .navigationBar:
            height += 44.0
        case .standard:
            height += 64.0
        }
        return height >= minimumHeight ? height : minimumHeight
    }
    
    fileprivate func updateHeight(dropHeight: DropHeight = .standard) {
        let height = getHeight(dropHeight: dropHeight)
        heightConstraint?.constant = height >= minimumHeight ? height : minimumHeight
        self.layoutIfNeeded()
    }
}

extension Drop {
    
    public class func down(_ status: String, height: DropHeight = .standard, state: DropState = .default, duration: Double = 4.0, action: DropAction? = nil) {
        
        UIApplication.shared.delegate?.window??.windowLevel = .statusBar
        show(status, height: height, state: state, duration: duration, action: action)
    }

    public class func down<T: DropStatable>(_ status: String, height: DropHeight = .standard, state: T, duration: Double = 4.0, action: DropAction? = nil) {
        UIApplication.shared.delegate?.window??.windowLevel = .statusBar
        show(status, height: height, state: state, duration: duration, action: action)
    }

    fileprivate class func show(_ status: String, height: DropHeight = .standard, state: DropStatable, duration: Double, action: DropAction?) {
        UIApplication.shared.delegate?.window??.windowLevel = .statusBar
        self.upAll()
        let drop = Drop(duration: duration)
        UIApplication.shared.keyWindow?.addSubview(drop)
        guard let window = drop.window else { return }

        var heightConstraint: NSLayoutConstraint!
        
        switch height {
        case .statusBar:
            heightConstraint = NSLayoutConstraint(item: drop, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: drop.getHeight(dropHeight: .statusBar))
        case .navigationBar:
            heightConstraint = NSLayoutConstraint(item: drop, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: drop.getHeight(dropHeight: .navigationBar))
        case .standard:
            heightConstraint = NSLayoutConstraint(item: drop, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: drop.getHeight(dropHeight: .standard))
        }
        
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

        drop.setup(status, dropHeight: height, state: state)
        drop.action = action
        drop.updateHeight(dropHeight: height)
        
        guard let superview = drop.superview else { return }
        superview.layoutIfNeeded()
        
        topConstraint.constant = 0.0
        UIView.animate(
            withDuration: TimeInterval(0.25),
            delay: TimeInterval(0.0),
            options: [.allowUserInteraction, .curveEaseOut],
            animations: {
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
            animations: {
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
    fileprivate func setup(_ status: String, dropHeight: DropHeight = .standard, state: DropStatable) {
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
        
        let notchHeight: CGFloat = getDeviceNotchHeight()
        let dropHeight: CGFloat = getHeight(dropHeight: dropHeight)
        let labelSpace: CGSize = CGSize(width: UIScreen.main.bounds.width, height: dropHeight - notchHeight)
        let statusLabel = UILabel()
        let heightInset: CGFloat = 3
        let widthInset:CGFloat = 5
        statusLabel.frame.size.width = labelSpace.width - (widthInset * 2)
        statusLabel.frame.size.height = labelSpace.height - (heightInset * 2)
        labelParentView.addSubview(statusLabel)
        statusLabel.frame.origin.x = widthInset
        statusLabel.frame.origin.y = notchHeight + heightInset
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.minimumScaleFactor = 10.0
        statusLabel.text = status
        statusLabel.textColor = state.textColor ?? .white
        self.statusLabel = statusLabel
        
        NotificationCenter.default.addObserver(self, selector: #selector(Drop.deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.up(_:))))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:))))
        self.layoutIfNeeded()
    }
}

extension Drop {
    @objc func up(_ sender: AnyObject) {
        action?()
        self.up()
    }
    
    @objc func pan(_ sender: AnyObject) {
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
                    animations: {
                        superview.layoutIfNeeded()
                    }, completion: nil
                )
                UIApplication.shared.delegate?.window??.windowLevel = .normal
            }
        case .failed, .cancelled:
            startTop = nil
            scheduleUpTimer(2.0)
            UIApplication.shared.delegate?.window??.windowLevel = .normal
        case .possible: break
        }
    }
}
