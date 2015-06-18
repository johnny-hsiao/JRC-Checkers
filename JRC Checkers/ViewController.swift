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
    
    @IBOutlet var popupMessage: UILabel!
    
    @IBOutlet var popupYes: UIButton!
    
    @IBOutlet var popupNo: UIButton!
    
    @IBOutlet var undoMoveButton: UIButton!
    
    @IBAction func resetButtonClicked(sender: UIButton) {
        showUserMsgNButtons()
    }
    
    @IBAction func yesClicked(sender: UIButton) {
        board.resetGame()
        hideUserMsgNButtons()
        
    }
    
    @IBAction func noClicked(sender: UIButton) {
        hideUserMsgNButtons()
    }
    
    func showUserMsgNButtons() {
        popupMessage.hidden = false
        popupYes.hidden = false
        popupNo.hidden = false
    }
    
    func hideUserMsgNButtons() {
        popupMessage.hidden = true
        popupYes.hidden = true
        popupNo.hidden = true
    }
    
    @IBAction func undoMove(sender: UIButton) {
        board.undoMove()
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

