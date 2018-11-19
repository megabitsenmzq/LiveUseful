//
//  BuildLivePhoto.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/15.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import Foundation
import MobileCoreServices
import ImageIO

class JPEG {
    fileprivate let kFigAppleMakerNote_AssetIdentifier = "17"
    fileprivate let image : CGImage

    init(image : CGImage) {
        self.image = image
    }

    func write(_ dest : URL, assetIdentifier : String) {
        guard let dest = CGImageDestinationCreateWithURL(dest as CFURL, kUTTypeJPEG, 1, nil)
            else { return }
        defer { CGImageDestinationFinalize(dest) }

        let makerNote = NSMutableDictionary()
        let metadata = NSMutableDictionary()
        makerNote.setObject(assetIdentifier, forKey: kFigAppleMakerNote_AssetIdentifier as NSCopying)
        metadata.setObject(makerNote, forKey: kCGImagePropertyMakerAppleDictionary as String as String as NSCopying)
        CGImageDestinationAddImage(dest, image, metadata)
    }
}
