//
//  AddQRDialogViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/6/16.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

protocol AddQRDialogDelegate: class {
    func getResultFromQRDialog(_ qrContent: String, title: String, canceled: Bool)
}

class AddQRDialogViewController: UIViewController, UITextViewDelegate, QRScannerDelegate {

    @IBOutlet var dialogView: UIView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var contentWordCount: UILabel!
    @IBOutlet var titleWordCount: UILabel!
    
    var defaultContent = ""
    var defaultTitle = ""
    var stopToggleKeyboard = false
    
    weak var delegate: AddQRDialogDelegate?
    
    @IBAction func cancel(_ sender: Any) {
        stopToggleKeyboard = true
        contentTextView.resignFirstResponder()
        titleTextView.resignFirstResponder()
        delegate?.getResultFromQRDialog("", title: "", canceled: true)
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func ok(_ sender: Any) {
        stopToggleKeyboard = true
        contentTextView.resignFirstResponder()
        titleTextView.resignFirstResponder()
        var title = ""
        if titleTextView.text != NSLocalizedString("Input title here (Optional).", comment: "Input title here (Optional).") {
            title = titleTextView.text
        }
        delegate?.getResultFromQRDialog(contentTextView.text, title: title, canceled: false)
        dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.delegate = self
        titleTextView.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        backButton.accessibilityLabel = NSLocalizedString("Cancel", comment: "Cancel")
        okButton.accessibilityLabel = NSLocalizedString("OK", comment: "OK")
        
        titleTextView.text = NSLocalizedString("Input title here (Optional).", comment: "Input title here (Optional).")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: contentTextView)
        
        if defaultContent != "" {
            contentTextView.text = defaultContent
            textViewDidChange(contentTextView)
            defaultContent = ""
        }
        
        if defaultTitle != "" {
            titleTextView.text = defaultTitle
            textViewDidChange(titleTextView)
            defaultTitle = ""
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        tapticGenerator.impactOccurred()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        if !titleTextView.isFirstResponder && !stopToggleKeyboard {
            contentTextView.becomeFirstResponder()
        }

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
        //Raise dialog when keyboard show
        dialogView.translatesAutoresizingMaskIntoConstraints = true
        let userInfo:NSDictionary = (notif as NSNotification).userInfo! as NSDictionary
        let keyBoardInfo: AnyObject? = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as AnyObject?
        let keyBoardHeight = (keyBoardInfo?.cgRectValue.size.height)!
        let toolsYWithoutKeyboard = view.frame.height/2 - dialogView.frame.height/2
        if keyBoardHeight > 10 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.dialogView.frame.origin.y = toolsYWithoutKeyboard - keyBoardHeight/3
            })
        }
    }
    
    @objc func keyboardWillHide() {
        //Reset dialog position
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dialogView.frame.origin.y = self.view.frame.height/2 -  self.dialogView.frame.height/2
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == contentTextView {
            let range = textView.markedTextRange
            if range == nil {
                if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                    let length = textView.text.utf8.count
                    contentWordCount.text = "\(length)/150"
                    if length > 150 {
                        contentWordCount.textColor = UIColor.red
                        okButton.isEnabled = false
                    } else {
                        contentWordCount.textColor = UIColor.black
                        okButton.isEnabled = true
                    }
                } else {
                    okButton.isEnabled = false
                }
            }
        } else if textView == titleTextView {
            let length = textView.text.count
            titleWordCount.text = "\(length)/10"
            if length > 150 {
                titleWordCount.textColor = UIColor.red
                okButton.isEnabled = false
            } else {
                if contentTextView.text != "" {
                    titleWordCount.textColor = UIColor.black
                    okButton.isEnabled = true
                }
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == contentTextView {
            if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
                textView.text = ""
                okButton.isEnabled = false
            }
        } else if textView == titleTextView {
            if textView.text.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
                textView.text = NSLocalizedString("Input title here (Optional).", comment: "Input title here (Optional).")
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == NSLocalizedString("Input title here (Optional).", comment: "Input title here (Optional).") {
            textView.text = ""
        }
    }
    
    func getResultFromQRScanner(_ qrContent: String) {
        contentTextView.text = qrContent
        textViewDidChange(contentTextView)
    }
}
