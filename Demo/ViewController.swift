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

        navigationController?.isNavigationBarHidden = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.upAllDrops(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @IBAction func showStatesAlert(_ sender: AnyObject) {
        let defaultAction = UIAlertAction(title: "Default", style: .default) { [unowned self] action -> Void in
            Drop.down(self.sampleText())
        }
        let infoAction = UIAlertAction(title: "Info", style: .default) { _ in
            Drop.down(self.sampleText(), state: .info)
        }
        let successAction = UIAlertAction(title: "Success", style: .default) { _ in
            Drop.down(self.sampleText(), state: .success)
        }
        let warningAction = UIAlertAction(title: "Warning", style: .default) { _ in
            Drop.down(self.sampleText(), state: .warning)
        }
        let errorAction = UIAlertAction(title: "Error", style: .default) { _ in
            Drop.down(self.sampleText(), state: .error)
        }
        let colorAction = UIAlertAction(title: "Custom color", style: .default) { _ in
            let r = CGFloat(arc4random_uniform(256))
            let g = CGFloat(arc4random_uniform(256))
            let b = CGFloat(arc4random_uniform(256))
            let color = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
            Drop.down(self.sampleText(), state: .color(color))
        }
        let actionableAction = UIAlertAction(title: "Action", style: .default) { [unowned self] action -> Void in
            Drop.down(self.sampleText()) {
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                let controller = UIAlertController(title: "Action", message: "Action fired!", preferredStyle: .alert)
                controller.addAction(action)
                self.present(controller, animated: true, completion: nil)
            }
        }
        let blurAction = UIAlertAction(title: "Blur", style: .default) { _ in
            Drop.down(self.sampleText(), state: .blur(.light))
        }
        let customAction = UIAlertAction(title: "Custom", style: .default) { _ in
            enum Custom: DropStatable {
                case blackGreen
                var backgroundColor: UIColor? {
                    switch self {
                    case .blackGreen: return .black
                    }
                }
                var font: UIFont? {
                    switch self {
                    case .blackGreen: return UIFont(name: "HelveticaNeue-Light", size: 24.0)
                    }
                }
                var textColor: UIColor? {
                    switch self {
                        case .blackGreen: return .green
                    }
                }
                var blurEffect: UIBlurEffect? {
                    switch self {
                    case .blackGreen: return nil
                    }
                }
            }
            Drop.down(self.sampleText(), state: Custom.blackGreen)
        }
        let durationAction = UIAlertAction(title: "Duration", style: .default) { [unowned self] action -> Void in
            self.showDurationAlert()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let controller = UIAlertController(title: "Samples", message: "Select to show drop down message.", preferredStyle: .actionSheet)
        for action in [defaultAction, infoAction, successAction, warningAction, errorAction, colorAction, actionableAction, blurAction, customAction, durationAction, cancelAction] {
            controller.addAction(action)
        }
        showAlert(controller, sourceView: sender as? UIView)
    }
    
    func showDurationAlert() {
        let durations = [0.5, 1.0, 2.0, 4.0, 6.0, 10.0, 20.0]
        let actions = durations.map { seconds in
            return UIAlertAction(title: "\(seconds)", style: .default) { _ in
                Drop.down(self.sampleText(), state: .default, duration: seconds)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let controller = UIAlertController(title: "Duration", message: "Select to duration. Default is 4 seconds.", preferredStyle: .actionSheet)
        for action in [cancelAction] + actions {
            controller.addAction(action)
        }
        showAlert(controller)
    }
    
    func showAlert(_ controller: UIAlertController, sourceView: UIView? = nil) {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            if let sourceView = sourceView {
                let rect = sourceView.convert(sourceView.bounds, to: view)
                controller.popoverPresentationController?.sourceView = view
                controller.popoverPresentationController?.sourceRect = rect
            }
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    func upAllDrops(_ sender: AnyObject) {
        if let hidden = navigationController?.isNavigationBarHidden {
            navigationController?.setNavigationBarHidden(!hidden, animated: true)
        }

        Drop.upAll()
    }
    
    func sampleText() -> String {
        let text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        let length = Int(arc4random_uniform(100)) + 10
        let end = text.characters.index(text.startIndex, offsetBy: length)
        return text.substring(with: (text.startIndex ..< end))
    }
}
