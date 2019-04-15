//
//  AddImageViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2017/12/30.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
import Photos

class AddImageViewController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate, LImagePickerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var frontImageView: UIImageView!
    @IBOutlet var snapshotView: UIView!
    @IBOutlet var toolsBackgroundView: UIView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var thumbnailButton: UIButton!
    @IBOutlet var thumbnailLabel: UILabel!
    @IBOutlet var coverButton: UIButton!
    @IBOutlet var coverLabel: UILabel!
    @IBOutlet var accessibilityTipLabel: UILabel!
    @IBOutlet var blurButton: UIButton!
    @IBOutlet var roundCornerButton: UIButton!
    @IBOutlet var contentModeButton: UIButton!
    @IBOutlet var bottomTools: UIView!
    @IBOutlet var backgroundBlur: UIVisualEffectView!

    var imagePicker = LImagePicker()
    let imageViewInScrollView = UIImageView(frame: CGRect(origin: CGPoint(x:0, y:0), size: croppedImage!.size))
    
    var currentImage:UIImage?{
        get{
            if isRoundCorner && contentMode{
                return tempImageRound
            } else {
                //Return images for different modes.
                if contentMode {
                    frontImageView.layer.cornerRadius = 0
                } else {
                    if isRoundCorner {
                        frontImageView.layer.cornerRadius = 10
                    } else {
                        frontImageView.layer.cornerRadius = 0
                    }
                }
                return tempImage
            }
        }
    }
    
    var isShowTools = false
    var isHasTempImage = false
    var stackMode = true {
        didSet{
            tempStackMode = stackMode
            thumbnailButton.isEnabled = stackMode
            thumbnailLabel.isEnabled = stackMode
            coverButton.isEnabled = !stackMode
            coverLabel.isEnabled = !stackMode
            
            if stackMode {
                thumbnailLabel.accessibilityTraits = .selected
                coverLabel.accessibilityTraits = .none
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    self.previewView.alpha = 1
                    self.scrollView.alpha = 0
                    self.accessibilityTipLabel.isHidden = true
                    self.bottomTools.alpha = 1
                })
            } else {
                thumbnailLabel.accessibilityTraits = .none
                coverLabel.accessibilityTraits = .selected
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                    self.previewView.alpha = 0
                    self.scrollView.alpha = 1
                    self.accessibilityTipLabel.isHidden = false
                    self.bottomTools.alpha = 0
                })
            }
        }
    }
    
    var toolsTempOriginY: CGFloat = 0
    var previewTempOriginY: CGFloat = 0
    
    var isRoundCorner = true {
        didSet{
            frontImageView.image = currentImage
            tempIsRoundCorner = isRoundCorner
            if isRoundCorner {
                roundCornerButton.setImage(#imageLiteral(resourceName: "RectCorner"), for: .normal)
                roundCornerButton.accessibilityTraits = .selected
            } else {
                roundCornerButton.setImage(#imageLiteral(resourceName: "RoundCorner"), for: .normal)
                roundCornerButton.accessibilityTraits = .none
            }
        }
    }
    
    var isBlur = false {
        didSet{
            if isBlur {
                blurButton.setImage(#imageLiteral(resourceName: "NoBlur"), for: .normal)
                blurButton.accessibilityTraits = .selected
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                    self.backgroundBlur.effect = UIBlurEffect(style: .regular)
                })
            } else {
                blurButton.setImage(#imageLiteral(resourceName: "Blur"), for: .normal)
                blurButton.accessibilityTraits = .none
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                    self.backgroundBlur.effect = .none
                })
            }
            tempIsBlur = isBlur
        }
    }
    
    var contentMode = true {
        didSet{
            if contentMode {
                frontImageView.contentMode = .scaleAspectFit
                contentModeButton.setImage(#imageLiteral(resourceName: "ShowBig"), for: .normal)
                contentModeButton.accessibilityLabel = NSLocalizedString("Scale to fit", comment: "Scale to fit")
            } else {
                frontImageView.contentMode = .scaleAspectFill
                contentModeButton.setImage(#imageLiteral(resourceName: "ShowSmall"), for: .normal)
                contentModeButton.accessibilityLabel = NSLocalizedString("Scale to fill", comment: "Scale to fill")
            }
            frontImageView.image = currentImage
            tempContentMode = contentMode
        }
    }
    
    @IBAction func setThumbnail(_ sender: Any) {
        stackMode = true
    }
    
    @IBAction func setCover(_ sender: Any) {
        stackMode = false
    }
    
    @IBAction func changeCorner(_ sender: Any) {
        tapticGenerator.impactOccurred()
        isRoundCorner = !isRoundCorner
    }
    
    @IBAction func setBlur(_ sender: Any) {
        tapticGenerator.impactOccurred()
        isBlur = !isBlur
    }
    
    @IBAction func setContentMode(_ sender: Any) {
        tapticGenerator.impactOccurred()
        contentMode = !contentMode
    }
    
    @IBAction func reSelectImage(_ sender: Any) {
        present(self.imagePicker.imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.previewView.frame.origin = CGPoint(x:0, y:self.view.frame.height)
            self.scrollView.alpha = 0
        })
        showAndHideTools({
            self.dismiss(animated: false, completion: {})
        })
    }
    
    @IBAction func ok(_ sender: Any) {
        
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
            self.scrollView.alpha = 0
            self.backgroundBlur.effect = .none
        }, completion: { (finished: Bool) in
            self.performSegue(withIdentifier: "toBuildFromImage", sender: self)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 10
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        scrollView.addSubview(imageViewInScrollView)
        
        imageView.image = croppedImage
        
        imagePicker.delegate = self
        
        toolsBackgroundView.isHidden = true
        backgroundBlur.effect = .none
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        okButton.accessibilityLabel = NSLocalizedString("OK", comment: "OK")
        
        if tempImage == nil {
            DispatchQueue.main.async(execute: { //Can't show imagePicker in WillDidLoad in iOS 10
                self.present(self.imagePicker.imagePickerController, animated: true, completion: nil)
            })
            
            isRoundCorner = true
            contentMode = true
            isBlur = false
        } else {
            if importType != nil {
				//存在导入内容则使用默认设置
                importType = nil
                isRoundCorner = true
                contentMode = true
                isBlur = false
                setImageInScrollView(image: tempImage!)
            } else {
                frontImageView.image = currentImage
                imageViewInScrollView.image = tempImage
                imageViewInScrollView.frame.size = tempImage!.size
                scrollView.minimumZoomScale = getMinimumZoomScale(image: tempImage!)
                scrollView.zoomScale = tempZoom
                scrollView.contentOffset.x = tempScroll.x
                scrollView.contentOffset.y = tempScroll.y
                
                isRoundCorner = tempIsRoundCorner
                contentMode = tempContentMode
                isBlur = tempIsBlur
            }
            
            toolsBackgroundView.isHidden = false
            isHasTempImage = true
            okButton.isEnabled = true
        }
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolsTempOriginY = toolsBackgroundView.frame.origin.y
        previewTempOriginY = previewView.frame.origin.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isHasTempImage == true {
            bottomTools.isHidden = false
            previewView.frame.origin = CGPoint(x:0, y:view.frame.height)
            showAndHideTools({})
            isHasTempImage = false
        } else {
            isShowTools = true
        }
        stackMode = tempStackMode
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tapticGenerator.impactOccurred()
        super.viewWillDisappear(animated)
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancel(self)
        return true
    }
    
    func imagePicker(imagePicker: LImagePicker, pickedImage: UIImage) {
        tempImage = pickedImage
        tempImageRound = pickedImage.roundedImage
        frontImageView.image = currentImage
        
        setImageInScrollView(image: pickedImage)
        
        toolsBackgroundView.isHidden = false
        okButton.isEnabled = true
        bottomTools.isHidden = false
    }
    
    func setImageInScrollView(image: UIImage) {
        //Restore to default scale in order to calculate correct new size
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        
        imageViewInScrollView.image = image
        imageViewInScrollView.frame.size = image.size
        scrollView.minimumZoomScale = getMinimumZoomScale(image: image)
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.contentOffset.x = image.size.width * scrollView.minimumZoomScale / 2 - view.frame.width / 2
        scrollView.contentOffset.y = image.size.height * scrollView.minimumZoomScale / 2 - view.frame.height / 2
        tempScroll = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y)
        tempZoom = scrollView.zoomScale
    }
    
    func imagePickerDidCancel(imagePicker: LImagePicker) {
        if tempImage == nil {
            tapticGenerator.impactOccurred()
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: false, completion: {})
            })
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewInScrollView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tempZoom = scrollView.zoomScale
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tempScroll = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y)
    }
    
    func getMinimumZoomScale(image: UIImage) -> CGFloat {
        var minimumZoomScale:CGFloat = 1.0
        let widthMinimumScale = view.frame.width / image.size.width
        let heightMinimumScale = view.frame.height / image.size.height
        
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
        
        return minimumZoomScale
    }
    
    func showAndHideTools(_ afterAnimation: @escaping () -> ()) {
        if isShowTools {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                self.toolsBackgroundView.frame.origin = CGPoint(x:0, y:0 - self.toolsBackgroundView.frame.height)
                self.bottomTools.alpha = 0
            }, completion: { (finished: Bool) in
                self.isShowTools = false
                afterAnimation()
            })
        } else {
            toolsBackgroundView.frame.origin = CGPoint(x:0, y: 0 - toolsBackgroundView.frame.height)
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                self.toolsBackgroundView.frame.origin.y = self.toolsTempOriginY
                self.previewView.frame.origin.y = self.previewTempOriginY
                if self.stackMode{
                    self.bottomTools.alpha = 1
                }
            }, completion: { (finished: Bool) in
                self.isShowTools = true
                afterAnimation()
            })
        }
    }
}
