//
//  ProViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/3.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
//import AppCenterAnalytics

class ProViewController: UIViewController, iapDelegate {

    @IBOutlet var purchaceButton: UIButton!
    @IBOutlet var restoreButton: UIButton!
    @IBOutlet var adImage: UIImageView!
    @IBOutlet var adDescription: UILabel!
    @IBOutlet var proIapIndicatior: UIActivityIndicatorView!
    @IBOutlet var restoreIapIndicatior: UIActivityIndicatorView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        purchaceButton.setBackgroundImage(UIImage(color:UIColor.black,size:purchaceButton.frame.size), for: .normal)
        adDescription.text = NSLocalizedString("IAP 1", comment: "IAP 1")
        
        inAppPurchase.delegate = self
        inAppPurchase.fetchAvailableProducts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: titleLabel)
    }
    
    override func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: {})
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func cancel(_ sender: Any) {
        tapticGenerator.impactOccurred()
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func purchase(_ sender: Any) {
//        MSAnalytics.trackEvent("Purchase Pro")
        
        purchaceButton.setTitle("", for: .normal)
        purchaceButton.isEnabled = false
        restoreButton.isEnabled = false
        proIapIndicatior.isHidden = false
        inAppPurchase.purchaseMyProduct(product: inAppPurchase.iapProducts[0])
        tapticGenerator.impactOccurred()
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        restoreButton.setTitle("", for: .normal)
        purchaceButton.isEnabled = false
        restoreButton.isEnabled = false
        restoreIapIndicatior.isHidden = false
        inAppPurchase.restorePurchase()
        tapticGenerator.impactOccurred()
    }
    
    //Refresh price tag
    func iapRefreshed() {
        purchaceButton.setTitle("LiveUseful Pro: " + inAppPurchase.priceStrings[0], for: .normal)
        purchaceButton.isEnabled = true
        restoreButton.isEnabled = true
        proIapIndicatior.isHidden = true
    }
    
    func iapPurchased() {
        tapticGenerator.impactOccurred()
        proAccessibilityLabel = nil
        dismiss(animated: true, completion: {})
    }
    
    func TransactionsFinished(_ message: String?) {
        purchaceButton.setTitle("LiveUseful Pro: " + inAppPurchase.priceStrings[0], for: .normal)
        purchaceButton.isEnabled = true
        proIapIndicatior.isHidden = true
        restoreButton.isEnabled = true
        if message != nil {
            let alert = UIAlertController(title: NSLocalizedString("Can't Purchase", comment: "Can't Purchase"), message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (action) -> Void in
            }
            alert.addAction(okAction)
            self.present(alert, animated:true, completion: nil)
        }
    }
    
    func iapRestoreFailed(_ message: String?) {
        purchaceButton.isEnabled = true
        restoreButton.setTitle(NSLocalizedString("Restore Purchase", comment: "Restore Purchase"), for: .normal)
        restoreButton.isEnabled = true
        restoreIapIndicatior.isHidden = true
        if message != nil {
            let alert = UIAlertController(title: NSLocalizedString("Can't Restore", comment: "Can't Restore"), message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (action) -> Void in
            }
            alert.addAction(okAction)
            self.present(alert, animated:true, completion: nil)
        }
    }
    
    func iapError() {
        let alert = UIAlertController(title: NSLocalizedString("Can't Purchase", comment: "Can't Purchase"), message: NSLocalizedString("In app purchases are disabled in your device!", comment: "In app purchases are disabled in your device!"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { (action) -> Void in
            self.TransactionsFinished(nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated:true, completion: nil)
    }
}
