//
//  AddMultipleQRViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/6/16.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
import CoreImage
//import AppCenterAnalytics

class AddMultipleQRViewController: UIViewController, QRViewDelegate, AddQRDialogDelegate{
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var snapshotView: UIView!
    @IBOutlet var toolsBackgroundView: UIView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var cardStyleButton: UIButton!
    @IBOutlet var changeSizeButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var qrImageSmall: UIImageView!
    @IBOutlet var qrCardView: UIVisualEffectView!
    @IBOutlet var qrCardViewSmall: UIVisualEffectView!
    @IBOutlet var backgroundBlur: UIVisualEffectView!
    @IBOutlet var moveQRPanRecognizer: UIPanGestureRecognizer!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var lastTimeLabel: UILabel!
    @IBOutlet var lastQRLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var descriptionLabel2: UILabel!
    @IBOutlet var timerBackground: UIView!
    @IBOutlet var timerBackground2: UIView!
    @IBOutlet var addNewQRButton: UIButton!
    @IBOutlet var titleBackground: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tipLabel: UILabel!
    @IBOutlet var accessibilityTipLabel: UILabel!
    
    var isShowPlaceHolder = true
    var isShowTools = true
    var isShowingKeyboards = false
    
    var toolsTempOriginY: CGFloat = 0
    var previewTempOriginY: CGFloat = 0
    var editId: Int? = nil
        
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
            tempCurrentSize = currentSize
            if currentSize {
                changeSizeButton.setImage(#imageLiteral(resourceName: "ShowBig"), for: .normal)
                changeSizeButton.accessibilityValue = NSLocalizedString("Small", comment: "Small")
                accessibilityTipLabel.isHidden = false
            } else {
                changeSizeButton.setImage(#imageLiteral(resourceName: "ShowSmall"), for: .normal)
                changeSizeButton.accessibilityValue = NSLocalizedString("Big", comment: "Big")
                accessibilityTipLabel.isHidden = true
            }
        }
    }
    
    var qrViews = [QRView]()
    
    @IBAction func toSingle(_ sender: Any) {
        tapticGenerator.impactOccurred()
        self.presentingViewController?.viewDidLayoutSubviews()
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func addNewQR(_ sender: Any) {
        tapticGenerator.impactOccurred()
    }

    @IBAction func cancel(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.previewView.frame.origin = CGPoint(x:0, y:self.view.frame.height)
        })
        showAndHideTools({
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {})
        })
    }
    
    @IBAction func ok(_ sender: Any) {
//        MSAnalytics.trackEvent("Add Multiple QR")
        
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
            self.descriptionLabel.isHidden = true
            self.descriptionLabel2.isHidden = true
            var lastQR = tempMultipleQR.count
            if lastQR == 1 {
                self.timerBackground.isHidden = true
                self.timerBackground2.isHidden = true
            }
            for aQR in self.qrViews {
                self.lastQRLabel.text = "\(lastQR - 1)"
                self.timerBackground.backgroundColor = self.getColorOfTag(id: lastQR - 1)
                self.timerBackground2.backgroundColor = self.timerBackground.backgroundColor
                self.qrImageView.image = aQR.qrImage
                self.qrImageSmall.image = self.qrImageView.image
                
                if tempMultipleQR[aQR.id].title != "" {
                    self.titleBackground.isHidden = false
                    self.titleLabel.text = tempMultipleQR[aQR.id].title
                } else {
                    self.titleBackground.isHidden = true
                }
                
                for i in 0...2 {
                    if lastQR == 1 { //Won't count down at last QR
                        self.lastTimeLabel.text = "0"
                    } else {
                        self.lastTimeLabel.text = "\(3 - i)"
                    }
                    autoreleasepool {
                        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
                        self.snapshotView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: targetSize), afterScreenUpdates: true)
                        let aImage = UIGraphicsGetImageFromCurrentImageContext()!.jpegData(compressionQuality: 1)!
                        sequenceImages.append(aImage)
                        UIGraphicsEndImageContext()
                    }
                    if lastQR == 1{
                        break
                    }
                }
                lastQR -= 1
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.previewView.alpha = 0
                self.backgroundBlur.effect = .none
            }, completion: { (finished: Bool) in
                self.performSegue(withIdentifier: "toBuildFromMultipleQR", sender: self)
            })
        })
    }
    
    @IBAction func changeCardStyle(_ sender: Any) {
        tapticGenerator.impactOccurred()
        cardStyle += 1
    }
    
    @IBAction func changeSize(_ sender: Any) {
        currentSize = !currentSize
        tapticGenerator.impactOccurred()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = croppedImage
        qrImageView.image = UIImage().generateQR(text: "Aburaya-Xoesan-Megabits-Maverick")
        qrImageSmall.image = qrImageView.image
        backgroundBlur.effect = .none
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        okButton.accessibilityLabel = NSLocalizedString("OK", comment: "OK")
        
        cardStyleButton.accessibilityLabel = NSLocalizedString("Card Style", comment: "Card Style")
        changeSizeButton.accessibilityLabel = NSLocalizedString("QR size", comment: "QR size")
        
        accessibilityTipLabel.text = NSLocalizedString("Move QR Tip", comment: "Move QR Tip")
        
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
        
        accessibilityTipLabel.accessibilityFrame = previewView.convert(qrCardViewSmall.frame, to: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cardStyle = tempQRCardStyle
        currentSize = tempCurrentSize
        
        if tempMultipleQR.count > 0 {
            for aQR in tempMultipleQR {
                let aView = QRView(frame: CGRect(x: 0, y: 0, width: stackView.frame.height, height: stackView.frame.height), qrImage: aQR.image)
                aView.delegate = self
                aView.id = qrViews.count
                stackView.insertArrangedSubview(aView, at: qrViews.count)
                qrViews.append(aView)
                okButton.isEnabled = true
            }
            tipLabel.isHidden = true
            qrImageView.image = qrViews.last?.qrImage
            qrImageSmall.image = qrImageView.image
            
            if tempMultipleQR.count >= 5 {
                addNewQRButton.isEnabled = false
            }
        }
        lastQRLabel.text = "\(tempMultipleQR.count)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tapticGenerator.impactOccurred()
        qrViews.removeAll() //Release memory
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let qrVC = segue.destination as? AddQRDialogViewController {
            qrVC.delegate = self
            if editId != nil {
                qrVC.defaultContent = tempMultipleQR[editId!].content
                qrVC.defaultTitle = tempMultipleQR[editId!].title
            }
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancel(self)
        return true
    }
    
    func getResultFromQRDialog(_ qrContent: String, title: String, canceled: Bool) {
        if canceled {
            editId = nil
            return
        }
        if editId != nil { //Back from edit
            if qrContent != tempMultipleQR[editId!].content {
                qrViews[editId!].qrImage = UIImage().generateQR(text: qrContent)
                qrImageView.image = qrViews.last!.qrImage
                qrImageSmall.image = qrImageView.image
            }
            tempMultipleQR[editId!] = (image: qrViews[editId!].qrImage!, content: qrContent, title: title)
            editId = nil
            return
        }
        let qrImage = UIImage().generateQR(text: qrContent)
        let aView = QRView(frame: CGRect(x: 0, y: 0, width: stackView.frame.height, height: stackView.frame.height), qrImage: qrImage)
        aView.delegate = self
        aView.id = qrViews.count
        stackView.insertArrangedSubview(aView, at: qrViews.count)
        qrViews.append(aView)
        tempMultipleQR.append((image: qrImage, content: qrContent, title: title))
        qrImageView.image = qrImage
        qrImageSmall.image = qrImageView.image
        
        lastQRLabel.text = "\(tempMultipleQR.count)"
        
        //Scroll to bottom
        if scrollView.contentSize.width + scrollView.contentSize.height > view.frame.width {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentSize.width + scrollView.contentSize.height - view.frame.width, y: 0), animated: true)
        }
        okButton.isEnabled = true
        tipLabel.isHidden = true
        
        if tempMultipleQR.count >= 5 {
            addNewQRButton.isEnabled = false
        }
    }
    
    func removeItem(id: Int) {
        tapticGenerator.impactOccurred()
        
        stackView.removeArrangedSubview(qrViews[id])
        qrViews[id].removeFromSuperview()
        qrViews.remove(at: id)
        tempMultipleQR.remove(at: id)
        //Update ids
        for aQRView in qrViews {
            if aQRView.id > id {
                aQRView.id -= 1
            }
        }
        
        //Placeholder
        if tempMultipleQR.count == 0 {
            okButton.isEnabled = false
            qrImageView.image = UIImage().generateQR(text: "Aburaya-Xoesan-Megabits-Maverick")
            qrImageSmall.image = qrImageView.image
        } else {
            qrImageView.image = qrViews.last!.qrImage
            qrImageSmall.image = qrImageView.image
            if tempMultipleQR.count < 3 {
                addNewQRButton.isEnabled = true
            }
        }
        lastQRLabel.text = "\(tempMultipleQR.count)"
    }
    
    func editItem(id: Int) {
        editId = id
        tapticGenerator.impactOccurred()
        performSegue(withIdentifier: "toDialog", sender: self)
    }
    
    func getColorOfTag(id: Int) -> UIColor {
        switch id {
        case 0:
            return colorRed
        case 1:
            return colorYellow
        case 2:
            return colorBlue
        case 3:
            return colorPurple
        case 4:
            return colorGray
        default:return colorRed
        }
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
