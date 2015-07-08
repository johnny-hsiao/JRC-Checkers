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
    
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!

    @IBAction func confirmReset(sender: AnyObject) {
        board.resetGame()
        hideButtons()
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        hideButtons()
    }
    
    @IBAction func resetButtonClicked(sender: UIButton) {
        popUpLabel.hidden = false
        yesButton.hidden = false
        noButton.hidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hideButtons()
    }
    
    func hideButtons() {
        popUpLabel.hidden = true
        yesButton.hidden = true
        noButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

