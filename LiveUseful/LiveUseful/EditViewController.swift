//
//  EditViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2017/12/9.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
import StoreKit

class EditViewController: UIViewController {

    @IBOutlet var toolbarView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var toolbarStackView: UIStackView!
    @IBOutlet var addThingsToolbarView: UIView!
    
    var tempOriginY: CGFloat = 0
    var addThingstempOrigin = CGPoint()
    var isShowTools = false

    @IBAction func pop(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.resetAll()
        tempText = ""
        showAndHideTools({})
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func helpAndInfo(_ sender: Any) {
        tapticGenerator.impactOccurred()
        performSegue(withIdentifier: "toAbout", sender: self)
    }
    
    @IBAction func toText(_ sender: Any) {
        showAndHideTools({
            self.isShowTools = false
            self.performSegue(withIdentifier: "toText", sender: self)
        })
    }
    
    @IBAction func toImage(_ sender: Any) {
        showAndHideTools({
            self.isShowTools = false
            self.performSegue(withIdentifier: "toImage", sender: self)
        })
    }
    
    @IBAction func toQR(_ sender: Any) {
        showAndHideTools({
            self.isShowTools = false
            self.performSegue(withIdentifier: "toQR", sender: self)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editViewController = self
        
        tempOriginY = toolbarView.frame.origin.y
        addThingstempOrigin = addThingsToolbarView.frame.origin
        
        imageView.image = croppedImage
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
		toolbarView.isHidden = true
		toolbarStackView.isHidden = true
		let appGroupName = "group.liveuseful"
		
		//准备内容，如果存在导入则不显示 UI 元素
		switch importType {
		case .Text?:
			tempText = UserDefaults(suiteName: appGroupName)!.string(forKey: ImportKeys.Text.rawValue) ?? ""
			importType = nil
			self.performSegue(withIdentifier: "toText", sender: self)
			return
		case .URL?:
			tempQR = UserDefaults(suiteName: appGroupName)!.url(forKey: ImportKeys.URL.rawValue)?.absoluteString ?? ""
			importType = nil
			self.performSegue(withIdentifier: "toQR", sender: self)
			return
		case .Image?:
			tempImage = UIImage(data: UserDefaults(suiteName: appGroupName)!.data(forKey: ImportKeys.Image.rawValue)!)
			tempImageRound = tempImage!.roundedImage
			self.performSegue(withIdentifier: "toImage", sender: self)
			return
		default: break
		}
		
        toolbarView.isHidden = false
        toolbarStackView.isHidden = false
        
        showAndHideTools({
            if rateCount == 2 {
                SKStoreReviewController.requestReview()
                rateCount = 0
            }
        })
    }
    
    override func accessibilityPerformEscape() -> Bool {
        pop(self)
        return true
    }

    func showAndHideTools(_ afterAnimation: @escaping () -> ()) {
        tapticGenerator.impactOccurred()
        if isShowTools {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.toolbarView.frame.origin = CGPoint(x:self.toolbarView.frame.origin.x, y:self.view.frame.height)
                self.addThingsToolbarView.frame.origin = CGPoint(x:self.addThingsToolbarView.frame.origin.x, y:self.view.frame.height)
                self.addThingsToolbarView.alpha = 0
            }, completion: { (finished: Bool) in
                self.isShowTools = false
                afterAnimation()
            })
        } else {
            view.setNeedsLayout()
            toolbarView.frame.origin.y = view.frame.height
            addThingsToolbarView.frame.origin = CGPoint(x:addThingstempOrigin.x, y:view.frame.height)
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                self.addThingsToolbarView.frame.origin = self.addThingstempOrigin
                self.toolbarView.frame.origin.y = self.tempOriginY
                self.addThingsToolbarView.alpha = 1
            }, completion: { (finished: Bool) in
                self.isShowTools = true
                afterAnimation()
            })
        }
    }
}
