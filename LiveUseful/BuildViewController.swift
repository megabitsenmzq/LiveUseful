//
//  BuildViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2017/12/27.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
import PhotosUI
//import AppCenterAnalytics

class BuildViewController: UIViewController, PHLivePhotoViewDelegate{

    @IBOutlet var livePhotoView: PHLivePhotoView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet var alertBackground: UIVisualEffectView!
    @IBOutlet var alertView: UIView!
    @IBOutlet var tipView: UIView!
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet var saveButton: UIButton!
    
    var saved = false

    @IBAction func back(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.resetAll()
        //Hide views in previous VC
        cropViewController?.toolbarView.isHidden = true
        editViewController?.toolbarView.isHidden = true
        editViewController?.toolbarStackView.isHidden = true
        view.window?.rootViewController?.dismiss(animated: true, completion: {})
    }
    
    @IBAction func save(_ sender: UIButton) {
        if saved { //Change button to "Open Photos" after saved
            let url  = "photos-redirect://"
            UIApplication.shared.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)
            return
        }
        
//        MSAnalytics.trackEvent("Save LivePhoto")
        
        tapticGenerator.impactOccurred()
        
        //Rate counter
        if rateCount < 2 {
            rateCount += 1
        }
        alertBackground.isHidden = false
        
        //Change to "Open Photos"
        sender.setImage(#imageLiteral(resourceName: "ToPhotos"), for: .normal)
        sender.accessibilityLabel = NSLocalizedString("Open photos", comment: "Open photos")
        saved = true
        
        //Save file if "never show alert" was set
        if isSeeItBanned {
            livePhotoBuilder.save()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.alertBackground.effect = UIBlurEffect(style: .extraLight)
                self.alertView.alpha = 1
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.alertBackground.effect = .none
                    self.alertView.alpha = 0
                }, completion: { (finished: Bool) in
                    self.alertBackground.isHidden = true
                })
            })
        } else {
            performSegue(withIdentifier: "seeIt", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        MSAnalytics.trackEvent("Build LivePhoto")
        
        livePhotoView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(backWhenEnterForeground), name: UIApplication.willEnterForegroundNotification, object:nil)
        
        imageView.image = croppedImage
        alertBackground.effect = .none
        
        //Save last background image
        if !isUsingLastImage {
            DispatchQueue.global().async {
                let imageURL = URL(fileURLWithPath: (documentsPath as NSString).appendingPathComponent("last.jpg"))
                do{
                    try croppedImage!.jpegData(compressionQuality: 1)?.write(to: imageURL)
                } catch {
                    print(error)
                }
            }
        }
        
        //Build files
        livePhotoBuilder.build(coverImage: croppedImage!, sequenceImage: sequenceImages, {(livePhoto) -> Void in
            self.livePhotoView.livePhoto = livePhoto
            tapticGenerator.impactOccurred()
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.livePhotoView.alpha = 1
                self.toolbarView.alpha = 1
                self.tipView.alpha = 0.6
            }, completion: { (finished: Bool) in
                self.loading.isHidden = true
            })
        })
        sequenceImages.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: saveButton)
        
        //Show saved message when back from SeeItVC
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.alertBackground.effect = UIBlurEffect(style: .extraLight)
            self.alertView.alpha = 1
        }, completion: { (finished: Bool) in
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                self.alertBackground.effect = .none
                self.alertView.alpha = 0
            }, completion: { (finished: Bool) in
                self.alertBackground.isHidden = true
            })
        })
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    //Hide tips when press screen
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        UIView.animate(withDuration: 0.1, animations: {
            self.tipView.alpha = 0.6
        })
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        UIView.animate(withDuration: 0.3, animations: {
            self.tipView.alpha = 0
        })
    }
    
    //Back to startVC if saved
    @objc func backWhenEnterForeground() {
        if saved {
            back(self)
        }
    }
}
