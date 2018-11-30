# LiveUseful - Make your lock screen useful!
![Use for iOS](https://img.shields.io/badge/platform-iOS-green.svg) [![Made with Swift](https://img.shields.io/badge/language-swift4.0-orange.svg)](https://github.com/apple/swift) [![Use MIT license](https://img.shields.io/badge/license-MIT¿-blue.svg)](https://opensource.org/licenses/MIT)

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fxdvmzaamsj31k90gowk8.jpg)

## About

LiveUseful is the first universal tool that inserts various hidden information into a Live Photo. Use these Live Photos, you can hide important things in your lock screen, and show them with 3D Touch. 

See more details on App Store: [LiveUseful - Make your lock screen useful!](https://itunes.apple.com/us/app/id1329941178) 

There are some apps in the App Store copied my idea(a universal tool that inserts various hidden information into a Live Photo). I have killed some of them, but there are still some apps I can't take them off. Even Apple now decide not to reply to any mail from me. I really have no idea, so I decide to make my app opensource. I hope you can use my code to make a unique lock screen card for your app, or just run my code and have fun. ^_^

## About the code

The core of LiveUseful is Live Photo。The App takes a screenshot of the view, then make a video from this image contain only one frame. Convert this video to Live Photo with a cover image as the background. When you press the screen with 3D Touch, it will start to play the video, display the image with hidden content. Because Live Photo has a built-in fade animation, the process will be very smooth.

A Live Photo is made from two parts: a JPEG image and a QuickTime video. You need to generate them separately then combine them as a Live Photo. And you also need to add some metadata to the files in order to join them together.

### Take screenshots

The video will be generated from a screenshot of the snapshotView. This view containing the background image and a card view above it.

To make this screenshot, you need to make a UIGraphicsImageContext. With drawHierarchy() function, you can get a screenshot of a view and ignore anything above it. In this case, I want the editing tools to be ignored.

```Swift
UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
self.snapshotView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: targetSize), afterScreenUpdates: true)
let aImage = UIGraphicsGetImageFromCurrentImageContext()!.jpegData(compressionQuality: 1)!
sequenceImages.append(aImage)
UIGraphicsEndImageContext()
```

See "AddTextViewController.swift" to learn more.

### Add metadata to files

For the image, you need to add some metadata to the file in order to link it with the video.

First, you need to generate a unique identifier. In my app, I use the UUID of the device.

Then set kCGImagePropertyMakerAppleDictionary to it. The dictionary now looks like: [17:assetIdentifier]. 17 means kFigAppleMakerNote_AssetIdentifier.

```Swift
makerNote.setObject(assetIdentifier, forKey: kFigAppleMakerNote_AssetIdentifier as NSCopying)
metadata.setObject(makerNote, forKey: kCGImagePropertyMakerAppleDictionary as String as String as NSCopying)
CGImageDestinationAddImage(dest, image, metadata)
```

See "FileProcess/JPEG.swift" to learn more.

For the video, you need to pass a metadata adapter to the asset writer.

```Swift
let spec : NSDictionary = [
           kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
           "\(kKeySpaceQuickTimeMetadata)/\(kKeyStillImageTime)",
           kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
           "com.apple.metadata.datatype.int8"   
```

This app is using AVFoundation to generate video from images. To understand what's happening in this step, you may need to learn AVFoundation.

See "FileProcess/QuickTimeMov.swift" to learn more.

### Make Live Photos

To make a Live Photo use for Live Photo view, you need to save the image and video to file first. Then you can pass the URL to PHLivePhoto.request() function.

```Swift
PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL], placeholderImage: nil, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, resultHandler: { (livePhoto, info) -> Void in 
    doSomethingWithResult(livePhoto)
    print(info)
})
```

To make a Live Photo for saving, you need to do the same thing with PHAssetCreationRequest.forAsset() function.

```Swift
let creationRequest = PHAssetCreationRequest.forAsset()
let options = PHAssetResourceCreationOptions()
creationRequest.addResource(with: PHAssetResourceType.photo, fileURL: self.imageURL, options: options)
creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: self.videoURL, options: options)
```

Then save the file with PHPhotoLibrary.shared().performChanges() function.

See "BuildLivePhoto.swift" to learn more.

## Design

LiveUseful was designed using Sketch. You can download the .sketch file in the "Design" folder.

![Screenshot](https://i.imgur.com/hh3GyTT.png)

## Donate

To support me, you can buy this app on App Store, or donate with WeChat or AliPay:

[![](https://qrtag.net/api/qr_transparent_4.svg?url=https://wx.tenpay.com/f2f?t=AQAAAJmau5%2FexSWV6HOdMOTrYQ0%3D)](https://wx.tenpay.com/f2f?t=AQAAAJmau5%2FexSWV6HOdMOTrYQ0%3D)

[![](https://qrtag.net/api/qr_transparent_4.svg?url=HTTPS://QR.ALIPAY.COM/FKX03104PXEOHVFMZKFFAA)](HTTPS://QR.ALIPAY.COM/FKX03104PXEOHVFMZKFFAA)

## Licence - MIT

LiveUseful is using MIT as open source license. But with an additional term: You could use part of the code, but do not upload this whole app to App Store by yourself.
