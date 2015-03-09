//
//  ViewController.swift
//  JRC Checkers
//
//  Created by Shark on 2015-02-12.
//  Copyright (c) 2015 Jollyrancher Corp. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var board: BoardView!
    
    @IBOutlet var resetButton: UIButton!
    
    @IBOutlet var popupMessage: UILabel!
    
    @IBOutlet var popupYes: UIButton!
    
    @IBOutlet var popupNo: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    
    
    @IBAction func resetButtonClicked(sender: UIButton) {
        showUserMsgNButtons()
    }
    
    @IBAction func yesClicked(sender: UIButton) {
 //       board.resetGame()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("pieceMoveSound", ofType: "wav")!)
        println(alertSound)
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    

        
    

}

