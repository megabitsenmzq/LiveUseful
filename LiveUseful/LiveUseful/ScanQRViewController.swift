//
//  ScanQRViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/1/21.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRScannerDelegate: class {
    func getResultFromQRScanner(_ qrContent: String)
}

class ScanQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var toolsBackgroundView: UIView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var openImageButton: UIButton!
    @IBOutlet var alertBackground: UIVisualEffectView!
    @IBOutlet var alertView: UIView!
    @IBOutlet var errorLabel: UILabel!
    
    //Prepare
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let supportedCodeTypes = [
        AVMetadataObject.ObjectType.upce,
        AVMetadataObject.ObjectType.code39,
        AVMetadataObject.ObjectType.code39Mod43,
        AVMetadataObject.ObjectType.code93,
        AVMetadataObject.ObjectType.code128,
        AVMetadataObject.ObjectType.ean8,
        AVMetadataObject.ObjectType.ean13,
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.pdf417,
        AVMetadataObject.ObjectType.itf14,
        AVMetadataObject.ObjectType.dataMatrix,
        AVMetadataObject.ObjectType.interleaved2of5,
        AVMetadataObject.ObjectType.qr
    ]

    let imagePicker = UIImagePickerController()
    
    weak var delegate: QRScannerDelegate?
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func openImage(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: {
            () -> Void in
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.preferredContentSize = UIScreen.main.bounds.size
        imagePicker.modalTransitionStyle = .crossDissolve
        alertBackground.effect = .none
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        
        //Camera session
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("No camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self , queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            //No permissions
            print(error)
            errorLabel.isHidden = false
            return
        }
        
        //Start capture
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        captureSession.startRunning()
        
        //Bring other views to front
        view.bringSubviewToFront(toolsBackgroundView)
        view.bringSubviewToFront(alertBackground)
        
        qrCodeFrameView = UIView()
        
        //Mark the QR code with a square
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        picker.dismiss(animated: false, completion: {
            () -> Void in
            let qrString = self.readQRImage(image)
            if qrString != "" {
                self.delegate?.getResultFromQRScanner(qrString)
                self.dismiss(animated: true, completion: {})
            }
        })
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            //QR code found
            if metadataObj.stringValue != nil {
                self.delegate?.getResultFromQRScanner(metadataObj.stringValue!)
                self.dismiss(animated: true, completion: {})
                
            }
        }
    }
    
    func readQRImage(_ image:UIImage) -> String{
        let ciImage: CIImage = CIImage(image: image)!
        let context = CIContext(options: nil)
        let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let features = detector.features(in: ciImage)
        //Use the last one
        var stringValue: String = ""
        if features.count != 0 {
            for feature in features as! [CIQRCodeFeature] {
                if feature.messageString != "" {
                    stringValue = feature.messageString!
                }
            }
        } else {
            tapticGenerator.impactOccurred()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.alertBackground.effect = UIBlurEffect(style: .extraLight)
                self.alertView.alpha = 1
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
                    self.alertBackground.effect = .none
                    self.alertView.alpha = 0
                }, completion: { (finished: Bool) in
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: NSLocalizedString("QR Code Not Found", comment: "QR Code Not Found"))
                })
            })
        }
        return stringValue
    }
}
