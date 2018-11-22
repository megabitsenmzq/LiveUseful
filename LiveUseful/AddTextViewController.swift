//
//  AddTextViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2017/12/25.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
//import AppCenterAnalytics

class AddTextViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var snapshotView: UIView!
    @IBOutlet var toolsBackgroundView: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textCardView: UIVisualEffectView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var textAlignButton: UIButton!
    @IBOutlet var cardStyleButton: UIButton!
    @IBOutlet var backgroundBlur: UIVisualEffectView!
    @IBOutlet var addListButton: UIButton!
    
    var isShowTools = false
    var cardStyle = 0 {
        didSet{
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                switch self.cardStyle {
                case 0:
                    self.textCardView.effect = UIBlurEffect(style: .extraLight)
                    self.backgroundBlur.effect = .none
                    self.textLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Extra light", comment: "Extra light")
                case 1:
                    self.textCardView.effect = UIBlurEffect(style: .light)
                    self.textLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Light", comment: "Light")
                case 2:
                    self.textCardView.effect = UIBlurEffect(style: .dark)
                    self.textLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Dark", comment: "Dark")
                case 3:
                    self.textCardView.effect = .none
                    self.backgroundBlur.effect = UIBlurEffect(style: .regular)
                    self.textLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Background blur", comment: "Background blur")
                default:
                    self.cardStyle = 0
                }
                tempTextCardStyle = self.cardStyle
            }, completion: { (finished: Bool) in
            })
        }
    }
    
    var textAlign = 0 {
        didSet{
            switch textAlign {
            case 0:
                textLabel.textAlignment = .left
                textAlignButton.setImage(#imageLiteral(resourceName: "AlignLeft"), for: UIControl.State.normal)
                textAlignButton.accessibilityValue = NSLocalizedString("Left", comment: "Left")
            case 1:
                textLabel.textAlignment = .center
                textAlignButton.setImage(#imageLiteral(resourceName: "AlignCenter"), for: UIControl.State.normal)
                textAlignButton.accessibilityValue = NSLocalizedString("Center", comment: "Center")
            case 2:
                textLabel.textAlignment = .right
                textAlignButton.setImage(#imageLiteral(resourceName: "AlignRight"), for: UIControl.State.normal)
                textAlignButton.accessibilityValue = NSLocalizedString("Right", comment: "Right")
            case 3:
                textLabel.textAlignment = .justified
                textAlignButton.setImage(#imageLiteral(resourceName: "AlignJustified"), for: UIControl.State.normal)
                textAlignButton.accessibilityValue = NSLocalizedString("Justified", comment: "Justified")
            default:
                DispatchQueue.main.async {
                    self.textAlign = 0
                }
            }
            tempTextAlign = textAlign
        }
    }
    
    var toolsTempOriginY: CGFloat = 0
    var previewTempOriginY: CGFloat = 0

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
//        MSAnalytics.trackEvent("Add Text")
        
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
        
        //Screenshot
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
        self.snapshotView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: targetSize), afterScreenUpdates: true)
        let aImage = UIGraphicsGetImageFromCurrentImageContext()!.jpegData(compressionQuality: 1)!
        sequenceImages.append(aImage)
        UIGraphicsEndImageContext()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            buildingView.effect = UIBlurEffect(style: .light)
            buildingIndicator.alpha = 1
            
            self.previewView.alpha = 0
            self.toolsBackgroundView.alpha = 0
            self.backgroundBlur.effect = .none
        }, completion: { (finished: Bool) in
            self.performSegue(withIdentifier: "toBuildFromText", sender: self)
        })
    }
    
    @IBAction func changeCardStyle(_ sender: Any) {
        tapticGenerator.impactOccurred()
        cardStyle += 1
    }
    
    @IBAction func changeTextAlign(_ sender: Any) {
        tapticGenerator.impactOccurred()
        textAlign += 1
    }

    @IBAction func setMaximumFontSize(_ sender: Any) {
        tapticGenerator.impactOccurred()
        
        let message = "\n\n\n\n\n\n"
        let alert = UIAlertController(title: NSLocalizedString("Set Maximum Font Size", comment: "Set Maximum Font Size"), message: message, preferredStyle: .actionSheet)
        alert.isModalInPopover = true
        let picker = UIPickerView(frame: CGRect(x: 0, y: 40, width: alert.view.frame.width, height: 150))
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(Int(textLabel.font.pointSize) - 20, inComponent: 0, animated: false)
        alert.view.addSubview(picker)
        picker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, multiplier: 1).isActive = true
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion: {
            picker.frame.size.width = alert.view.frame.width
        })
    }
    
    @IBAction func toList(_ sender: Any) {
        tapticGenerator.impactOccurred()
        textView.resignFirstResponder()
        performSegue(withIdentifier: "toList", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        
        imageView.image = croppedImage
        backgroundBlur.effect = .none
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        okButton.accessibilityLabel = NSLocalizedString("OK", comment: "OK")
        
        cardStyleButton.accessibilityLabel = NSLocalizedString("Card Style", comment: "Card Style")
        textAlignButton.accessibilityLabel = NSLocalizedString("Text alignment", comment: "Text alignment")
        
        if tempText != "" {
            textView.text = tempText
            textLabel.text = textView.text
            okButton.isEnabled = true
        } else {
            textView.text = NSLocalizedString("Input some text here.", comment: "Input some text here.")
            textLabel.text = "LiveUseful"
        }
        
        textLabel.font = UIFont(descriptor: textLabel.font.fontDescriptor, size: tempMaximumFontSize)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolsTempOriginY = toolsBackgroundView.frame.origin.y
        previewTempOriginY = previewView.frame.origin.y
        cardStyle = tempTextCardStyle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addListButton.accessibilityLabel = addListButton.title(for: .normal)!
        
        cardStyle = tempTextCardStyle
        textAlign = tempTextAlign
        
        if isShowTools == false {
            previewView.frame.origin = CGPoint(x:0, y:view.frame.height)
            showAndHideTools({})
        }
        
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: textView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tapticGenerator.impactOccurred()
        super.viewWillDisappear(animated)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancel(self)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == NSLocalizedString("Input some text here.", comment: "Input some text here.") {
            textView.text = ""
        }
        tapticGenerator.impactOccurred()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textLabel.text = textView.text
        tempText = textView.text
        if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
            okButton.isEnabled = true
        } else {
            okButton.isEnabled = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            textView.text = NSLocalizedString("Input some text here.", comment: "Input some text here.")
            textLabel.text = "LiveUseful"
            okButton.isEnabled = false
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
    
    //Font size selector
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x:0,y:0,width: 100,height: 40))
        label.text = "\(row + 20)"
        label.font = UIFont(descriptor: label.font.fontDescriptor, size: 20)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tempMaximumFontSize = CGFloat(row + 20)
        textLabel.font = UIFont(descriptor: textLabel.font.fontDescriptor, size: tempMaximumFontSize)
    }
}
