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
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func showMenu(sender: AnyObject) {
        let defaultAction = UIAlertAction(title: "Default", style: .Default) { [unowned self] action -> Void in
            Drop.down(self.sampleText())
        }
        let infoAction = UIAlertAction(title: "Info", style: .Default) { [unowned self] action -> Void in
            Drop.down(.Info, status: self.sampleText())
        }
        let warningAction = UIAlertAction(title: "Warning", style: .Default) { [unowned self] action -> Void in
            Drop.down(.Warning, status: self.sampleText())
        }
        let errorAction = UIAlertAction(title: "Error", style: .Default) { [unowned self] action -> Void in
            Drop.down(.Error, status: self.sampleText())
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let controller = UIAlertController(title: "Samples", message: "Select to show drop down alert.", preferredStyle: .ActionSheet)
        controller.addAction(defaultAction)
        controller.addAction(infoAction)
        controller.addAction(warningAction)
        controller.addAction(errorAction)
        controller.addAction(cancelAction)
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func sampleText() -> String {
        var text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        let length = Int(arc4random_uniform(400))
        let start = advance(text.startIndex, 10)
        let end = advance(start, length)
        return text.substringWithRange(Range(start: start, end: end))
    }
}