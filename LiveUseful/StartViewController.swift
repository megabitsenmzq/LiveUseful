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
    @IBOutlet var purchaseProButton: UIButton!
    
    let imagePicker = UIImagePickerController()

    @IBAction func purchasePro(_ sender: Any) {
        tapticGenerator.impactOccurred()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if inAppPurchase.isPro == true {
            purchaseProButton.isHidden = true
            proAccessibilityLabel = nil
        }
        
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
