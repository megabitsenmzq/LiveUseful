//
//  CropViewController.swift
//  UsefulLive
//
//  Created by Megabits on 2017/12/9.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit

class CropViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var toolbarView: UIView!
    @IBOutlet weak var importAlertView: UIView!
    
    @IBAction func removeImport(_ sender: Any) {
        importType = nil
        importAlertView.isHidden = true
    }
    
    @IBAction func pop(_ sender: Any) {
        tapticGenerator.impactOccurred()
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func crop(_ sender: Any) {
        let croppedCGImage = fixOrientation(img: imageView.image!).cgImage?.cropping(to: cropArea)
        //Make sure the image is stable
        croppedImage = UIImage(cgImage: croppedCGImage!)
        if abs(croppedImage!.size.width / view.frame.size.width - croppedImage!.size.height / view.frame.size.height) < 0.01{
            performSegue(withIdentifier: "toEdit", sender: self)
        }
    }

    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x:0, y:0), size: origenalImage!.size))
    
    var cropArea:CGRect{
        get{
            let scale = 1/scrollView.zoomScale
            let x = scrollView.contentOffset.x * scale
            let y = scrollView.contentOffset.y * scale
            let width = view.frame.size.width * scale
            let height = view.frame.size.height * scale
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    var tempOriginY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        cropViewController = self
        
        imageView.image = origenalImage
        scrollView.addSubview(imageView)
        
        //scale to fill
        let widthMinimumScale = view.frame.width / origenalImage!.size.width
        let heightMinimumScale = view.frame.height / origenalImage!.size.height
        var minimumZoomScale:CGFloat = 1.0
        
        if widthMinimumScale < 1 {
            if heightMinimumScale < 1 {
                minimumZoomScale = max(widthMinimumScale,heightMinimumScale)
            } else {
                minimumZoomScale = heightMinimumScale
            }
        } else {
            if heightMinimumScale < 1 {
                minimumZoomScale = widthMinimumScale
            } else {
                minimumZoomScale = max(widthMinimumScale,heightMinimumScale)
            }
        }
        
        //fix images in the wrong position
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = 10
        scrollView.zoomScale = minimumZoomScale
        scrollView.contentOffset.x = origenalImage!.size.width * minimumZoomScale / 2 - view.frame.width / 2
        scrollView.contentOffset.y = origenalImage!.size.height * minimumZoomScale / 2 - view.frame.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        becomeActive()
        
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tempOriginY = toolbarView.frame.origin.y
        toolbarView.frame.origin.y = view.frame.height
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.toolbarView.frame.origin.y = self.tempOriginY
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.toolbarView.frame.origin.y = self.view.frame.height
        }, completion: { (finished: Bool) in
            self.view.setNeedsLayout()
        })
        super.viewWillDisappear(animated)
    }
    
    //Draw "Z" with two fingers
    override func accessibilityPerformEscape() -> Bool {
        pop(self)
        return true
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        crop(self)
        return true
    }
    
    @objc func becomeActive() {
        if importType != nil {
            importAlertView.isHidden = false
        } else {
            importAlertView.isHidden = true
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //Some photos' orientation is just in the metadata, so rotate it first
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
}
