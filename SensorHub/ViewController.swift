//
//  ViewController.swift
//  SensorHub
//
//  Created by James Yu on 10/8/18.
//  Copyright © 2018 James Yu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var btn_standalone: UIButton!
    @IBOutlet weak var btn_rogernav: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func standaloneMode(_ sender: UIButton) {
        performSegue(withIdentifier: "segue_standalone", sender: nil)
    }
    
    @IBAction func rogernavMode(_ sender: UIButton) {
        performSegue(withIdentifier: "segue_rogernav", sender: nil)
    }
    
}

