//
//  AddQRViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/1/5.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
import CoreImage
//import AppCenterAnalytics

class AddQRViewController: UIViewController, UITextViewDelegate, QRScannerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var snapshotView: UIView!
    @IBOutlet var toolsBackgroundView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var cardStyleButton: UIButton!
    @IBOutlet var changeSizeButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var qrImage: UIImageView!
    @IBOutlet var qrImageSmall: UIImageView!
    @IBOutlet var qrCardView: UIVisualEffectView!
    @IBOutlet var qrCardViewSmall: UIVisualEffectView! 
    @IBOutlet var backgroundBlur: UIVisualEffectView!
    @IBOutlet var wordCount: UILabel!
    @IBOutlet var moveQRPanRecognizer: UIPanGestureRecognizer!
    @IBOutlet var addMultipleQRbutton: UIButton!
    @IBOutlet var accessibilityTipLabel: UILabel!
    
    var isShowTools = false
    var isShowingKeyboards = false
    
    var toolsTempOriginY: CGFloat = 0
    var previewTempOriginY: CGFloat = 0
        
    var cardStyle = 0 {
        didSet{
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                switch self.cardStyle {
                case 0:
                    self.backgroundBlur.effect = .none
                    self.qrCardView.effect = UIBlurEffect(style: .extraLight)
                    self.qrCardViewSmall.effect = UIBlurEffect(style: .extraLight)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Extra light", comment: "Extra light")
                case 1:
                    self.backgroundBlur.effect = .none
                    self.qrCardView.effect = UIBlurEffect(style: .light)
                    self.qrCardViewSmall.effect = UIBlurEffect(style: .light)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Light", comment: "Light")
                case 2:
                    self.backgroundBlur.effect = UIBlurEffect(style: .regular)
                    self.qrCardView.effect = .none
                    self.qrCardViewSmall.effect = .none
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Background blur", comment: "Background blur")
                default:
                    self.cardStyle = 0
                }
            })
            tempQRCardStyle = cardStyle
        }
    }
    
    var currentSize = true {
        didSet{
            qrCardView.isHidden = currentSize
            qrCardViewSmall.isHidden = !currentSize
            if currentSize && !isShowingKeyboards{
                moveQRPanRecognizer.isEnabled = true
            } else {
                moveQRPanRecognizer.isEnabled = false
            }
            if currentSize {
                changeSizeButton.setImage(#imageLiteral(resourceName: "ShowBig"), for: .normal)
                changeSizeButton.accessibilityValue = NSLocalizedString("Small", comment: "Small")
                accessibilityTipLabel.isHidden = false
            } else {
                changeSizeButton.setImage(#imageLiteral(resourceName: "ShowSmall"), for: .normal)
                changeSizeButton.accessibilityValue = NSLocalizedString("Big", comment: "Big")
                accessibilityTipLabel.isHidden = true
            }
            tempCurrentSize = currentSize
        }
    }
    
    @IBAction func hideKeyboardRecognizer(_ sender: Any) {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.previewView.frame.origin = CGPoint(x:0, y:self.view.frame.height)
        })
        showAndHideTools({
            self.dismiss(animated: false, completion: {})
        })
    }
    
    @IBAction func ok(_ sender: Any) {
//        MSAnalytics.trackEvent("Add QR")
        
        textView.resignFirstResponder()
        
        let buildingView = UIVisualEffectView(effect: .none)
        let buildingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        buildingIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        buildingIndicator.center = view.center
        buildingIndicator.startAnimating()
        buildingIndicator.alpha = 0
        buildingView.contentView.addSubview(buildingIndicator)
        buildingView.frame = CGRect(x:0, y:0, width:view.frame.width, height:view.frame.height)
        view.addSubview(buildingView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.qrCardViewSmall.frame.origin.y = qrCardViewSmallOriginY
            buildingView.effect = UIBlurEffect(style: .light)
            buildingIndicator.alpha = 1
            self.toolsBackgroundView.alpha = 0
        }, completion: { (finished: Bool) in
            //Screenshot
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
            self.snapshotView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: targetSize), afterScreenUpdates: true)
            let aImage = UIGraphicsGetImageFromCurrentImageContext()!.jpegData(compressionQuality: 1)!
            sequenceImages.append(aImage)
            UIGraphicsEndImageContext()
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.previewView.alpha = 0
                self.backgroundBlur.effect = .none
            }, completion: { (finished: Bool) in
                self.performSegue(withIdentifier: "toBuildFromQR", sender: self)
            })
        })
    }
    
    @IBAction func scanQR(_ sender: Any) {
        performSegue(withIdentifier: "toScan", sender: self)
    }
    
    @IBAction func changeCardStyle(_ sender: Any) {
        tapticGenerator.impactOccurred()
        cardStyle += 1
    }
    
    @IBAction func changeSize(_ sender: Any) {
        currentSize = !currentSize
        tapticGenerator.impactOccurred()
    }
    
    @IBAction func toMultiple(_ sender: Any) {
        tapticGenerator.impactOccurred()
        
        func show() {
            textView.resignFirstResponder()
            performSegue(withIdentifier: "toMultiple", sender: self)
        }
        if UIAccessibility.isVoiceOverRunning {
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Accessibility Warning",comment:"Accessibility Warning"), message: NSLocalizedString("Accessibility Warning Message",comment:"Accessibility Warning Message"), preferredStyle:  .alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK",comment:"OK"), style: .default, handler:{
                (action: UIAlertAction!) -> Void in
                show()
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel",comment:"Cancel"), style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            show()
        }
    }
    
    @IBAction func moveQR(_ sender: UIPanGestureRecognizer) {
        let qrTop = qrCardViewSmall.frame.origin.y
        let translation = sender.translation(in: view).y/20
        
        if qrTop + translation > 20 {
            if qrTop + translation < qrCardViewSmallOriginYLimit {
                qrCardViewSmall.frame.origin.y = qrTop + translation
            } else {
                qrCardViewSmall.frame.origin.y = qrCardViewSmallOriginYLimit
            }
        } else {
            qrCardViewSmall.frame.origin.y = 20
        }
        
        qrCardViewSmallOriginY = qrCardViewSmall.frame.origin.y
        accessibilityTipLabel.accessibilityFrame = previewView.convert(qrCardViewSmall.frame, to: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        imageView.image = croppedImage
        qrImage.image = UIImage().generateQR(text: "Aburaya-Xoesan-Megabits-Maverick")
        qrImageSmall.image = qrImage.image
        backgroundBlur.effect = .none
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        okButton.accessibilityLabel = NSLocalizedString("OK", comment: "OK")
        
        cardStyleButton.accessibilityLabel = NSLocalizedString("Card Style", comment: "Card Style")
        changeSizeButton.accessibilityLabel = NSLocalizedString("QR size", comment: "QR size")
        
        accessibilityTipLabel.text = NSLocalizedString("Move QR Tip", comment: "Move QR Tip")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolsTempOriginY = toolsBackgroundView.frame.origin.y
        previewTempOriginY = previewView.frame.origin.y
        
        if !isShowingKeyboards { //Layout will be reset when changing the QR size, so move it again
            if qrCardViewSmallOriginY != 0 {
                qrCardViewSmall.frame.origin.y = qrCardViewSmallOriginY
            } else {
                qrCardViewSmallOriginY = qrCardViewSmall.frame.origin.y
                qrCardViewSmallOriginYLimit = qrCardViewSmallOriginY
            }
        }
        
        cardStyle = tempQRCardStyle
        currentSize = tempCurrentSize
        
        accessibilityTipLabel.accessibilityFrame = previewView.convert(qrCardViewSmall.frame, to: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addMultipleQRbutton.accessibilityLabel = addMultipleQRbutton.title(for: .normal)!
        
        if isShowTools == false { //Won't show animations when back from ScanQRVC
            previewView.frame.origin = CGPoint(x:0, y:view.frame.height)
            showAndHideTools({})
        }
    
        if tempQR != "" {
            textView.text = tempQR
            textViewDidChange(textView)
        } else {
            textView.text = NSLocalizedString("Input text or URL here.", comment: "Input text or URL here.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tapticGenerator.impactOccurred()
        super.viewWillDisappear(animated)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let qrVC = segue.destination as? ScanQRViewController {
            qrVC.delegate = self
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancel(self)
        return true
    }
    
    @objc func keyboardWillShow(_ notif:Notification) {
        //Raise QR code when keyboard show
        let userInfo: NSDictionary = (notif as NSNotification).userInfo! as NSDictionary;
        let keyBoardInfo: AnyObject? = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as AnyObject?
        let keyBoardHeight = (keyBoardInfo?.cgRectValue.size.height)!
        if keyBoardHeight > 10 {
            accessibilityTipLabel.text = NSLocalizedString("Hide keyboard", comment: "Hide keyboard")
            moveQRPanRecognizer.isEnabled = false
            isShowingKeyboards = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.qrCardViewSmall.frame.origin.y = 20
                self.accessibilityTipLabel.accessibilityFrame = self.previewView.convert(self.qrCardViewSmall.frame, to: self.view)
            })
        }
    }
    
    @objc func keyboardWillHide() {
        isShowingKeyboards = false
        //Reset QR code position
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.qrCardViewSmall.frame.origin.y = qrCardViewSmallOriginY
        }, completion: { (finished: Bool) in
            self.moveQRPanRecognizer.isEnabled = true
            self.accessibilityTipLabel.accessibilityFrame = self.previewView.convert(self.qrCardViewSmall.frame, to: self.view)
            self.accessibilityTipLabel.text = NSLocalizedString("Move QR Tip", comment: "Move QR Tip")
        })
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == NSLocalizedString("Input text or URL here.", comment: "Input text or URL here.") {
            textView.text = ""
        }
        tapticGenerator.impactOccurred()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //Calculate a fullwidth character as 3 characters
        let range = textView.markedTextRange
        if range == nil {
            if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                let length = textView.text.utf8.count
                wordCount.text = "\(length)/150"
                if length > 150 {
                    wordCount.textColor = UIColor.red
                    okButton.isEnabled = false
                } else {
                    wordCount.textColor = UIColor.black
                    qrImage.image = UIImage().generateQR(text: textView.text)
                    qrImageSmall.image = qrImage.image
                    okButton.isEnabled = true
                }
            } else {
                qrImage.image = UIImage().generateQR(text: "Aburaya-Xoesan-Megabits-Maverick")
                qrImageSmall.image = qrImage.image
                okButton.isEnabled = false
            }
            tempQR = textView.text
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //Placeholder
        if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            textView.text = NSLocalizedString("Input text or URL here.", comment: "Input text or URL here.")
            wordCount.text = "0/150"
            wordCount.textColor = UIColor.black
            okButton.isEnabled = false
        }
    }
    
    func getResultFromQRScanner(_ qrContent: String) {
        tempQR = qrContent
    }
    
    func showAndHideTools(_ afterAnimation: @escaping () -> ()) {
        if isShowTools {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                self.toolsBackgroundView.frame.origin = CGPoint(x:0, y:0 - self.toolsBackgroundView.frame.height)
            }, completion: { (finished: Bool) in
                self.isShowTools = false
                afterAnimation()
            })
        } else {
            toolsBackgroundView.frame.origin = CGPoint(x:0, y: 0 - toolsBackgroundView.frame.height)
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                self.toolsBackgroundView.frame.origin.y = self.toolsTempOriginY
                self.previewView.frame.origin.y = self.previewTempOriginY
            }, completion: { (finished: Bool) in
                self.isShowTools = true
                afterAnimation()
            })
        }
    }
}
