//
//  Extensions.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/4.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

//Refresh view order for voiceover
extension UIView {
    func updateOrder(_ direction: Bool = true) {
        var tempElements: [Any]? = [Any]()
        let views = (direction) ? subviews : subviews.reversed()
        for aView in views {
            tempElements?.append(aView)
        }
        accessibilityElements = tempElements
    }
}

class ReorderAccessibilityByStoryBoardView: UIView {
    override func didAddSubview(_ subview: UIView) {
        updateOrder()
    }
}

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize) { //Round corner button background
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        let rect = CGRect(origin: CGPoint(x: 1, y:1), size: CGSize(width: size.width - 2, height: size.height - 2))
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners,cornerRadii: CGSize(width: rect.size.width/2, height: rect.size.height/2))
        path.lineWidth = 2
        color.setStroke()
        path.stroke()
        UIGraphicsGetCurrentContext()?.addPath(path.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func generateQR(text: String) -> UIImage {
        let data = text.data(using: String.Encoding.utf8)!
        
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let qrColorChanged = CIFilter(name: "CIFalseColor", parameters: ["inputImage": qr.outputImage!, "inputColor0": CIColor.black, "inputColor1": CIColor.clear])!
        let sizeTransform = CGAffineTransform(scaleX: 20, y: 20)
        let qrImage = qrColorChanged.outputImage!.transformed(by: sizeTransform)
        
        var qrUIImage = UIImage(ciImage: qrImage)
        UIGraphicsBeginImageContextWithOptions(qrUIImage.size, false, qrUIImage.scale)
        qrUIImage.draw(at: CGPoint.zero)
        qrUIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return qrUIImage
    }
    
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        let scale = max(self.size.width,self.size.height) / UIScreen.main.bounds.size.width
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 10 * scale
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

//fade images when press
extension UIButton {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.tag == 1 {
            self.alpha = 0.5
        }
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.tag == 1 {
            self.alpha = 1
        }
        super.touchesEnded(touches, with: event)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.tag == 1 {
            self.alpha = 1
        }
        super.touchesCancelled(touches, with: event)
    }
}
