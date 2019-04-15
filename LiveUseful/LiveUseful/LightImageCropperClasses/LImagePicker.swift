//
//  LImagePicker.swift
//  LImagePicker
//
//  Created by Jinyu Meng on 2018/6/9.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

public protocol LImagePickerDelegate: class {
     func imagePicker(imagePicker: LImagePicker, pickedImage: UIImage)
     func imagePickerDidCancel(imagePicker: LImagePicker)
}

public class LImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LImageCropControllerDelegate {
    
    public weak var delegate: LImagePickerDelegate?

    private var _imagePickerController: UIImagePickerController!

    public var imagePickerController: UIImagePickerController {
        return _imagePickerController
    }
    
    override public init() {
        super.init()

        _imagePickerController = UIImagePickerController()
        _imagePickerController.delegate = self
        _imagePickerController.sourceType = .photoLibrary
        _imagePickerController.modalTransitionStyle = .crossDissolve
    }

    private func hideController() {
        self._imagePickerController.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if self.delegate?.imagePickerDidCancel != nil {
            self.delegate?.imagePickerDidCancel(imagePicker: self)
        } else {
            self.hideController()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let cropController = LImageCropViewController()
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        cropController.sourceImage = image
        cropController.delegate = self
        picker.pushViewController(cropController, animated: true)
    }
    
    func imageCropController(imageCropController: LImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.delegate?.imagePicker(imagePicker: self, pickedImage: croppedImage)
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}
