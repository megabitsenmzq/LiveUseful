//
//  LImageCropView.swift
//  LImagePicker
//
//  Created by Jinyu Meng on 2018/6/9.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
import QuartzCore

private class ScrollView: UIScrollView {
    fileprivate override func layoutSubviews() {
        super.layoutSubviews()

        if let zoomView = self.delegate?.viewForZooming?(in: self) {
            let boundsSize = self.bounds.size
            var frameToCenter = zoomView.frame

            // center horizontally
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }

            // center vertically
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }

            zoomView.frame = frameToCenter
        }
    }
}

class LImageCropView: UIView, UIScrollViewDelegate {

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!
    private var cropOverlayView: LImageCropOverlayView!
    private var xOffset: CGFloat!
    private var yOffset: CGFloat!

    private static func scaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(
            x:rect.origin.x * scale,
            y:rect.origin.y * scale,
            width:rect.size.width * scale,
            height:rect.size.height * scale)
    }

    var imageToCrop: UIImage! {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
            
            let safeArea = CGSize(width: UIScreen.main.bounds.width * 0.85, height: UIScreen.main.bounds.height * 0.83)
            let imageSize = newValue.size
            let widthScale = safeArea.width / imageSize.width
            let heightScale = safeArea.height / imageSize.height
            var scale: CGFloat = 1.0
            if widthScale > 0 {
                scale = (heightScale > 0) ? min(widthScale, heightScale) : heightScale
            } else {
                scale = (heightScale > 0) ? widthScale : max(widthScale, heightScale)
            }
            
            cropSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        }
    }

    var cropSize: CGSize {
        get {
            return self.cropOverlayView.cropSize
        }
        set {
            if let view = self.cropOverlayView {
                view.cropSize = newValue
            } else {
                self.cropOverlayView = LResizableCropOverlayView(frame: self.bounds, initialContentSize: CGSize(width:newValue.width, height:newValue.height))
                self.cropOverlayView.cropSize = newValue
                self.addSubview(self.cropOverlayView)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.black
        self.scrollView = ScrollView(frame: frame)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.clipsToBounds = false
        self.scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
        self.scrollView.backgroundColor = UIColor.clear
        self.addSubview(self.scrollView)

        self.imageView = UIImageView(frame: self.scrollView.frame)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = UIColor.black
        self.scrollView.addSubview(self.imageView)

        self.scrollView.minimumZoomScale = self.scrollView.frame.width / self.scrollView.frame.height
        self.scrollView.maximumZoomScale = 20
        self.scrollView.setZoomScale(1.0, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = self.cropSize;
        let toolbarSize: CGFloat = 54
        self.xOffset = floor((self.bounds.width - size.width) * 0.5)
        self.yOffset = floor((self.bounds.height - toolbarSize - size.height) * 0.5)

        let height = self.imageToCrop!.size.height
        let width = self.imageToCrop!.size.width

        var factor: CGFloat = 0
        var factoredHeight: CGFloat = 0
        var factoredWidth: CGFloat = 0

        if width > height {
            factor = width / size.width
            factoredWidth = size.width
            factoredHeight =  height / factor
        } else {
            factor = height / size.height
            factoredWidth = width / factor
            factoredHeight = size.height
        }

        self.cropOverlayView.frame = self.bounds
        self.scrollView.frame = CGRect(x:xOffset, y:yOffset, width:size.width, height:size.height)
        self.scrollView.contentSize = CGSize(width:size.width, height:size.height)
        self.imageView.frame = CGRect(x:0, y:floor((size.height - factoredHeight) * 0.5), width:factoredWidth, height:factoredHeight)
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func croppedImage() -> UIImage {
        // Calculate rect that needs to be cropped
        var visibleRect = calcVisibleRectForResizeableCropArea()

        // transform visible rect to image orientation
        let rectTransform = orientationTransformedRectOfImage(image: imageToCrop!)
        visibleRect = visibleRect.applying(rectTransform);

        // finally crop image
        let imageRef = imageToCrop!.cgImage!.cropping(to: visibleRect)
        let result = UIImage(cgImage: imageRef!, scale: imageToCrop!.scale,
            orientation: imageToCrop!.imageOrientation)

        return result
    }

    private func calcVisibleRectForResizeableCropArea() -> CGRect {
        let resizableView = cropOverlayView as! LResizableCropOverlayView

        // first of all, get the size scale by taking a look at the real image dimensions. Here it 
        // doesn't matter if you take the width or the hight of the image, because it will always 
        // be scaled in the exact same proportion of the real image
        var sizeScale = self.imageView.image!.size.width / self.imageView.frame.size.width
        sizeScale *= self.scrollView.zoomScale

        // then get the postion of the cropping rect inside the image
        var visibleRect = resizableView.contentView.convert(resizableView.contentView.bounds,
                                                            to: imageView)
        visibleRect = LImageCropView.scaleRect(rect: visibleRect, scale: sizeScale)

        return visibleRect
    }

    private func orientationTransformedRectOfImage(image: UIImage) -> CGAffineTransform {
        var rectTransform: CGAffineTransform!

        switch image.imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2)).translatedBy(
                x: 0, y: -image.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2)).translatedBy(
                x: -image.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2)).translatedBy(
                x: -image.size.width, y: -image.size.height)
        default:
            rectTransform = CGAffineTransform.identity
        }

        return rectTransform.scaledBy(x: image.scale, y: image.scale)
    }
}
