//
//  SeeItViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/15.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

class SeeItViewController: UIViewController {

    @IBOutlet var okButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var iSeeButton: UIButton!
    
    var timer: Timer?
    var timeRemaining = 5
    
    @IBAction func ok(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func iSee(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isSeeItBanned")
        dismiss()
    }
    
    func dismiss() {
        livePhotoBuilder.save()
        isSeeItBanned = true
        tapticGenerator.impactOccurred()
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.setBackgroundImage(UIImage(color:UIColor.black,size:okButton.frame.size), for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @objc func updateTimer() {
        timeRemaining -= 1
        timerLabel.text = "\(timeRemaining)s"
        if timeRemaining == 0 {
            timer?.invalidate()
            timer = nil
            okButton.isEnabled = true
            iSeeButton.isEnabled = true
            timerLabel.isHidden = true
        }
    }
}
