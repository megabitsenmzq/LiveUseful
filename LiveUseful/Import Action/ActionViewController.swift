//
//  ActionViewController.swift
//  LiveUseful-action
//
//  Copyright © 2018 Megabits. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

class ActionViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var importQRButton: UIButton!
    @IBOutlet var importImageButton: UIButton!
    @IBOutlet var qrContentView: UILabel!
    @IBOutlet weak var maskView: UIView!
    
    @IBAction func importQR(_ sender: Any) {
        view.isUserInteractionEnabled = false
        
        UserDefaults(suiteName: appGroupName)!.set(qrString, forKey: ImportKeys.URL.rawValue)
		openMainApp(type: .URL)
        done()
    }
    
    @IBAction func importImage(_ sender: Any) {
        view.isUserInteractionEnabled = false
        
        UserDefaults(suiteName: appGroupName)!.set(imageView.image!.jpegData(compressionQuality: 1), forKey: ImportKeys.Image.rawValue)
		openMainApp(type: .Image)
        done()
    }
    
    var qrString = ""
	var itemType: ImportKeys? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                
                //Text
                if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (data, error) in
                        let input = data as! String
                        if input != "" {
                            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                            let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
                            if matches.count != 0 {
                                for match in matches {
                                    guard let range = Range(match.range, in: input) else { continue }
                                    let urlText = String(input[range])
                                    if let url = URL(string: urlText) {
                                        // Import url from text.
                                        UserDefaults(suiteName: appGroupName)!.set(url, forKey: ImportKeys.URL.rawValue)
                                        self.itemType = .URL
                                        return
                                    }
                                }
                            }
                            UserDefaults(suiteName: appGroupName)!.set(input, forKey: ImportKeys.Text.rawValue)
                            self.itemType = .Text
                            return
                        }
                    })
                }
                
                if provider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (data, error) in
                        if let url = data as? NSURL {
                            UserDefaults(suiteName: appGroupName)!.set(url.absoluteURL!, forKey: ImportKeys.URL.rawValue)
                                self.itemType = .URL
                                return
                        }
                    })
                }
                
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (data, error) in
                        let theImage: UIImage?
                        switch data {
                        case let image as UIImage:
                            theImage = image
                        case let data as Data:
                            theImage = UIImage(data: data)
                        case let url as URL:
                            theImage = UIImage(contentsOfFile: url.path)
                        default:
                            print("Unexpected data:", type(of: data))
                            theImage = nil
                        }
                        if theImage != nil {
                            OperationQueue.main.addOperation {
                                self.imageView.image = theImage
                                self.importImageButton.isEnabled = true
                            }
                            UserDefaults(suiteName: appGroupName)!.set(theImage?.jpegData(compressionQuality: 1), forKey: ImportKeys.Image.rawValue)
                            self.itemType = .Image
                        }
                    })
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if imageView.image != nil && qrString == "" {
            qrString = readQRImage(imageView.image!)
        }
        qrContentView.text = qrString
        if qrString != "" {
            importQRButton.isEnabled = true
        }
        if itemType == nil {
            done()
        }
        if itemType == .Text || itemType == .URL {
			openMainApp(type: itemType!)
            done()
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.maskView.alpha = 0
            })
        }
    }
    
    @objc func openURL(_ url: URL) {
        return
    }
    
    @IBAction func done() {
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
	func openMainApp(type: ImportKeys) {
        if let URL = URL(string: "liveuseful://" + type.rawValue) {
			// Open link in extension
            var responder: UIResponder? = (self as UIResponder)
            let selector = #selector(openURL(_:))
            while responder != nil {
                if responder!.responds(to: selector) && responder != self {
                    responder!.perform(selector, with: URL)
                    break
                }
                responder = responder?.next
            }
        }
    }
    
    func readQRImage(_ image:UIImage) -> String {
        let ciImage:CIImage=CIImage(image:image)!
        let context = CIContext(options: nil)
        let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: context, options:[CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let features=detector.features(in: ciImage)
        
        var stringValue:String = ""
        if features.count != 0 {
            for feature in features as! [CIQRCodeFeature] {
                stringValue = feature.messageString!
            }
        }
        return stringValue
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
}

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
