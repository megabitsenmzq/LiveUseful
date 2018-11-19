//
//  LImageCropViewController.swift
//  LImagePicker
//
//  Created by Jinyu Meng on 2018/6/9.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
import CoreGraphics

protocol LImageCropControllerDelegate: class {
    func imageCropController(imageCropController: LImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage)
}

class LImageCropViewController: UIViewController {
    
    var sourceImage: UIImage!
    weak var delegate: LImageCropControllerDelegate?

    private var croppedImage: UIImage!

    private var imageCropView: LImageCropView!
    private var toolbar: UIToolbar!
    private var useButton: UIButton!
    private var cancelButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupCropView()
        self.setupToolbar()
    }
    
    //Prevent notification center activating by accident in iOS 11
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .top
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.imageCropView.frame = self.view.bounds
        self.toolbar?.frame = CGRect(x:0, y:self.view.frame.height - 54, width:self.view.frame.size.width, height:54)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: useButton)
    }

    @objc func actionCancel(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func actionUse(sender: AnyObject) {
        self.croppedImage = self.imageCropView.croppedImage()
        self.delegate?.imageCropController(imageCropController: self, didFinishWithCroppedImage: self.croppedImage)
    }

    private func setupCropView() {
        
        self.imageCropView = LImageCropView(frame: self.view.bounds)
        self.imageCropView.imageToCrop = sourceImage
        self.view.addSubview(self.imageCropView)
    }

    private func setupCancelButton() {
        
        self.cancelButton = UIButton()
        self.cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.cancelButton.titleLabel?.shadowOffset = CGSize(width:0, height:-1)
        self.cancelButton.frame = CGRect(x:0, y:0, width:58, height:30)
        self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        self.cancelButton.setTitleShadowColor(
            UIColor(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal)
        self.cancelButton.addTarget(self, action: #selector(actionCancel), for: .touchUpInside)
    }

    private func setupUseButton() {
        
        self.useButton = UIButton()
        self.useButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.useButton.titleLabel?.shadowOffset = CGSize(width:0, height:-1)
        self.useButton.frame = CGRect(x:0, y:0, width:58, height:30)
        self.useButton.setTitle(NSLocalizedString("OK", comment: "OK"), for: .normal)
        self.useButton.setTitleShadowColor(
            UIColor(red: 0.118, green: 0.247, blue: 0.455, alpha: 1), for: .normal)
        self.useButton.addTarget(self, action: #selector(actionUse), for: .touchUpInside)
    }

    private func toolbarBackgroundImage() -> UIImage {
        
        let components: [CGFloat] = [1, 1, 1, 1, 123.0 / 255.0, 125.0 / 255.0, 132.0 / 255.0, 1]

        UIGraphicsBeginImageContextWithOptions(CGSize(width:320, height:54), true, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2)
        context!.drawLinearGradient(gradient!, start: CGPoint(x:0, y:0), end: CGPoint(x:0, y:54), options: [])

        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return viewImage!
    }

    private func setupToolbar() {
        self.toolbar = UIToolbar(frame: CGRect.zero)
        self.toolbar.isTranslucent = true
        self.toolbar.barStyle = .black
        self.view.addSubview(self.toolbar)

        self.setupCancelButton()
        self.setupUseButton()

        let info = UILabel(frame: CGRect.zero)
        info.text = ""
        info.textColor = UIColor(red: 0.173, green: 0.173, blue: 0.173, alpha: 1)
        info.backgroundColor = UIColor.clear
        info.shadowColor = UIColor(red: 0.827, green: 0.731, blue: 0.839, alpha: 1)
        info.shadowOffset = CGSize(width:0, height:1)
        info.font = UIFont.boldSystemFont(ofSize: 18)
        info.sizeToFit()

        let cancel = UIBarButtonItem(customView: self.cancelButton)
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let label = UIBarButtonItem(customView: info)
        let use = UIBarButtonItem(customView: self.useButton)

        self.toolbar.setItems([cancel, flex, label, flex, use], animated: false)
    }
}
