//
//  ViewController.swift
//  Example
//
//  Created by MORITANAOKI on 2015/06/20.
//  Copyright (c) 2015年 MORITANAOKI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBarHidden = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "upAllDrops:")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func showStatesAlert(sender: AnyObject) {
        let defaultAction = UIAlertAction(title: "Default", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText())
        }
        let infoAction = UIAlertAction(title: "Info", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText(), state: .Info)
        }
        let successAction = UIAlertAction(title: "Success", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText(), state: .Success)
        }
        let warningAction = UIAlertAction(title: "Warning", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText(), state: .Warning)
        }
        let errorAction = UIAlertAction(title: "Error", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText(), state: .Error)
        }
        let colorAction = UIAlertAction(title: "Custom color", style: .Default) { [unowned self] action -> Void in
            let r = CGFloat(arc4random_uniform(256))
            let g = CGFloat(arc4random_uniform(256))
            let b = CGFloat(arc4random_uniform(256))
            let color = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
            Drop.down(self.sampleText(), state: .Color(color))
        }
        let blurAction = UIAlertAction(title: "Blur", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText(), state: .Blur(.Light))
        }
        let customAction = UIAlertAction(title: "Custom", style: .Default) { [unowned self] action -> Void in
            enum Custom: DropStatable {
                case BlackGreen
                var backgroundColor: UIColor? {
                    switch self {
                    case .BlackGreen: return .blackColor()
                    }
                }
                var font: UIFont? {
                    switch self {
                    case .BlackGreen: return UIFont(name: "HelveticaNeue-Light", size: 24.0)
                    }
                }
                var textColor: UIColor? {
                    switch self {
                        case .BlackGreen: return .greenColor()
                    }
                }
                var blurEffect: UIBlurEffect? {
                    switch self {
                    case .BlackGreen: return nil
                    }
                }
            }
            Drop.down(self.sampleText(), state: Custom.BlackGreen)
        }
        let durationAction = UIAlertAction(title: "Duration", style: .Default) { [unowned self] action -> Void in
            self.showDurationAlert()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let controller = UIAlertController(title: "Samples", message: "Select to show drop down message.", preferredStyle: .ActionSheet)
        for action in [defaultAction, infoAction, successAction, warningAction, errorAction, colorAction, blurAction, customAction, durationAction, cancelAction] {
            controller.addAction(action)
        }
        showAlert(controller, sourceView: sender as? UIView)
    }
    
    func showDurationAlert() {
        let durations = [0.5, 1.0, 2.0, 4.0, 6.0, 10.0, 20.0]
        let actions = durations.map { seconds in
            return UIAlertAction(title: "\(seconds)", style: .Default) { [unowned self] action -> Void in
                Drop.down(self.sampleText(), state: .Default, duration: seconds)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let controller = UIAlertController(title: "Duration", message: "Select to duration. Default is 4 seconds.", preferredStyle: .ActionSheet)
        for action in [cancelAction] + actions {
            controller.addAction(action)
        }
        showAlert(controller)
    }
    
    func showAlert(controller: UIAlertController, sourceView: UIView? = nil) {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            if let sourceView = sourceView {
                let rect = sourceView.convertRect(sourceView.bounds, toView: view)
                controller.popoverPresentationController?.sourceView = view
                controller.popoverPresentationController?.sourceRect = rect
            }
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func upAllDrops(sender: AnyObject) {
        if let hidden = navigationController?.navigationBarHidden {
            navigationController?.setNavigationBarHidden(!hidden, animated: true)
        }

        Drop.upAll()
    }
    
    func sampleText() -> String {
        let text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        let length = Int(arc4random_uniform(100)) + 10
        let end = text.startIndex.advancedBy(length)
        return text.substringWithRange(Range(start: text.startIndex, end: end))
    }
}
