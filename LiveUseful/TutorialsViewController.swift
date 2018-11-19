//
//  TutorialsViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/1.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

class TutorialsViewController: UIViewController {

    
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var image4: UIImageView!
    @IBOutlet var mask: UIView!
    @IBOutlet var bigText: UILabel!
    @IBOutlet var smallText: UILabel!
    @IBOutlet var nextPage: UIButton!
    @IBOutlet var prevPage: UIButton!
    @IBOutlet var swipePrev: UISwipeGestureRecognizer!
    @IBOutlet var swipeNext: UISwipeGestureRecognizer!
    
    var page = 0 {
        didSet{
            switch page {
            case 0:
                bigText.text = NSLocalizedString("AD 1 Title", comment: "AD 1 Title")
                smallText.text = NSLocalizedString("AD 1 Subtitle", comment: "AD 1 Subtitle")
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    if !isTutorialsReaded {
                        self.prevPage.alpha = 0
                        self.swipePrev.isEnabled = false
                    }
                    self.image2.alpha = 0
                })
            case 1:
                bigText.text = NSLocalizedString("AD 2 Title", comment: "AD 2 Title")
                smallText.text = ""
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    self.prevPage.alpha = 1
                    self.swipePrev.isEnabled = true
                    self.image2.alpha = 1
                    self.mask.alpha = 0
                })
            case 2:
                bigText.text = NSLocalizedString("AD 3 Title", comment: "AD 3 Title")
                smallText.text = ""
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    self.mask.alpha = 1
                    self.image4.alpha = 0
                })
            case 3:
                bigText.text = NSLocalizedString("AD 4 Title", comment: "AD 4 Title")
                smallText.text = ""
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                    self.image4.alpha = 1
                })
            default:
                if page < 0 {
                    page = 0
                    if isTutorialsReaded {
                        dismiss(animated: true, completion: {})
                    }
                } else { //case >3
                    isTutorialsReaded = true
                    dismiss(animated: true, completion: {})
                }
            }
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        nextPage.isEnabled = false
        prevPage.isEnabled = false
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: bigText)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.bigText.alpha = 0
            self.smallText.alpha = 0
        }, completion: { (finished: Bool) in
            self.page += 1
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
            self.bigText.alpha = 1
            self.smallText.alpha = 1
        }, completion: { (finished: Bool) in
            self.nextPage.isEnabled = true
            self.prevPage.isEnabled = true
        })
    }
    
    @IBAction func prevPage(_ sender: Any) {
        nextPage.isEnabled = false
        prevPage.isEnabled = false
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: bigText)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.bigText.alpha = 0
            self.smallText.alpha = 0
        }, completion: { (finished: Bool) in
            self.page -= 1
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn, animations: {
            self.bigText.alpha = 1
            self.smallText.alpha = 1
        }, completion: { (finished: Bool) in
            self.nextPage.isEnabled = true
            self.prevPage.isEnabled = true
        })
        
    }
    
    override func viewDidLoad() {
        if isTutorialsReaded {
            self.prevPage.alpha = 1
            self.swipePrev.isEnabled = true
        }
        page = 0 //Refresh button state
    }
    
    override func accessibilityPerformEscape() -> Bool {
        if isTutorialsReaded {
            dismiss(animated: true, completion: {})
        }
        return true
    }
    
}
