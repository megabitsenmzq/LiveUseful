//
//  BuildLivePhoto.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/15.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit
import Photos

class BuildLivePhoto {
    let assetIdentifier = UUID().uuidString
    var imageURL: URL!
    var videoURL: URL!
    
    init() {
        imageURL = URL(fileURLWithPath: (documentsPath as NSString).appendingPathComponent("cover.jpg"))
        videoURL = URL(fileURLWithPath: (documentsPath as NSString).appendingPathComponent("videoClip.mov"))
//        print(videoURL)
    }
    
    func clean() {
        //Clear cache
        do {
            try FileManager.default.removeItem(at: imageURL)
            try FileManager.default.removeItem(at: videoURL)
        } catch { }
    }
    
    func build(coverImage: UIImage, sequenceImage: [Data], _ afterBuild: @escaping (_ livePhoto:PHLivePhoto?) -> ()) {
        clean()
        //Cover
        JPEG(image: coverImage.cgImage!).write(imageURL, assetIdentifier: self.assetIdentifier)
        //Video
        QuickTimeMov(image: sequenceImage).write(videoURL, assetIdentifier: self.assetIdentifier)
        //Combine LivePhoto
        PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL], placeholderImage: nil, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto, info) -> Void in
            afterBuild(livePhoto)
//                print(info)
        })
    }
    
    func save() {
        //Find album "LivePhoto"
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "LiveUseful")
        var collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        func savePhoto() {
            PHPhotoLibrary.shared().performChanges({ () -> Void in
                let creationRequest = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: self.imageURL, options: options)
                creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: self.videoURL, options: options)
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection.firstObject!)
                let placeHolder = creationRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            }, completionHandler: { (success, error) -> Void in
                if !success {
                    print(error!)
                }
            })
        }
        
        if collection.firstObject == nil {
            PHPhotoLibrary.shared().performChanges({ //Create album
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "LiveUseful")
            }) { success, _ in
                if success {
                    collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                    savePhoto()
                }
            }
        } else {
            savePhoto()
        }
    }
}
