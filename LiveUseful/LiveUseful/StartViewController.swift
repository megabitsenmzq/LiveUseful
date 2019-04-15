//
//  ViewController.swift
//  UsefulLive
//
//  Created by Megabits on 2017/9/30.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
import Photos

class StartViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var cantSaveImageTip: UIVisualEffectView!
    @IBOutlet var openPhotoView: UIView!
    @IBOutlet var openPhotoButton: UIButton!
    @IBOutlet var useLastPhotoButton: UIButton!
    @IBOutlet weak var importAlertView: UIView!
    
    let imagePicker = UIImagePickerController()
    var omakeCount = 0
    
    @IBAction func removeImport(_ sender: Any) {
        importType = nil
        importAlertView.isHidden = true
    }
    
    @IBAction func showOmake(_ sender: Any) {
        omakeCount += 1
        if omakeCount == 9 {
            omakeCount = 0
            performSegue(withIdentifier: "toOmake", sender: self)
        }
    }
    
    @IBAction func openSettings(_ sender: Any) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func selectImage(_ sender: Any) {
        tapticGenerator.impactOccurred()
        self.present(imagePicker, animated: true, completion: {
            () -> Void in
        })
    }
    
    @IBAction func useLastPhoto(_ sender: Any) {
        isUsingLastImage = true
        performSegue(withIdentifier: "toEditDirect", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set output size
        targetSize = CGSize(width: view.frame.width * 1.5, height: view.frame.height * 1.5)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.preferredContentSize = UIScreen.main.bounds.size
        imagePicker.modalTransitionStyle = .crossDissolve
        
        openPhotoButton.setBackgroundImage(UIImage(color:UIColor.black,size:openPhotoButton.frame.size), for: .normal)
        
        startViewController = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeActive()
        if isTutorialsReaded == true {
            getAuthorization()
        } else {
            performSegue(withIdentifier: "showTutorials", sender: self)
        }
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        if useLastPhotoButton.isEnabled == true {
            useLastPhoto(self)
        } else {
            selectImage(self)
        }
        return true
    }
    
    @objc func becomeActive() {
        if importType != nil {
            importAlertView.isHidden = false
        } else {
            importAlertView.isHidden = true
        }
    }

    func getAuthorization() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                if status != .authorized {
                    DispatchQueue.main.async {
                        self.cantSaveImageTip.isHidden = false
                        self.openPhotoView.isHidden = true
                    }
                }
            }
        } else if authStatus == .authorized  {
            cantSaveImageTip.isHidden = true
            openPhotoView.isHidden = false
            //Get the background image saved last time
            if let lastPhoto = UIImage(contentsOfFile: documentsPath + "/last.jpg") {
                self.useLastPhotoButton.isEnabled = true
                croppedImage = lastPhoto
            }
        } else {
            cantSaveImageTip.isHidden = false
            openPhotoView.isHidden = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        origenalImage = image
        picker.dismiss(animated: false, completion: {
            () -> Void in
        })
        
        //fix picker animation
        let snapshotView = picker.view.snapshotView(afterScreenUpdates: true)!
        view.addSubview(snapshotView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            snapshotView.removeFromSuperview()
        }
        performSegue(withIdentifier: "toCrop", sender: self)
    }
}
