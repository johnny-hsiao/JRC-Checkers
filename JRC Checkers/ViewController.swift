//
//  ViewController.swift
//  JRC Checkers
//
//  Created by Shark on 2015-02-12.
//  Copyright (c) 2015 Jollyrancher Corp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var board: BoardView!
    
    @IBOutlet var resetButton: UIButton!
    

    
    
    @IBAction func resetButtonClicked(sender: UIButton) {
        board.resetGame()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

