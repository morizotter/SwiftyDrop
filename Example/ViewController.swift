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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func drop(sender: AnyObject) {
        Drop.down("asdf;alkjas;lkdjfasd;lfkjasd;lfkjasd;flkjasdlfkjasdflkjasl;dkfjasdflkjajfkjdfksjfkajsfkjalsdfja;fljalfjalfjasd;lfjasldfigdhglsdkfhsdighusifguinaueiyiyewhudsfahdfahufalshjas;ldfjas;lfjasdlfjasf;ljadfjadfa")
    }
}

