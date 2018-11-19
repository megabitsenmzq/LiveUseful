//
//  QuickTimeMov.swift
//  LiveUseful
//
//  Created by Megabits on 2017/12/27.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
import AVFoundation

class QuickTimeMov {
    fileprivate let kKeyContentIdentifier =  "com.apple.quicktime.content.identifier"
    fileprivate let kKeyStillImageTime = "com.apple.quicktime.still-image-time"
    fileprivate let kKeySpaceQuickTimeMetadata = "mdta"
    fileprivate var image: [Data]
    fileprivate let dummyTimeRange = CMTimeRangeMake(start: CMTimeMake(value: 0, timescale: 1000), duration: CMTimeMake(value: 200, timescale: 3000))
    
    init(image: [Data]) {
        self.image = image
    }
    
    func write(_ dest : URL, assetIdentifier : String) {
        do {
            let writer = try AVAssetWriter(outputURL: dest, fileType: .mov)
            writer.metadata = [metadataFor(assetIdentifier)]
            
            var videoSettings = [String : Any]()
            let videoCompositionProps = [AVVideoAverageBitRateKey: 10000000]
            if #available(iOS 11.0, *) {
                videoSettings = [
                    AVVideoCodecKey  : AVVideoCodecType.h264,
                    AVVideoWidthKey  : targetSize.width,
                    AVVideoHeightKey : targetSize.height,
                    AVVideoCompressionPropertiesKey: videoCompositionProps
                ]
            } else {
                videoSettings = [
                    AVVideoCodecKey  : AVVideoCodecH264,
                    AVVideoWidthKey  : targetSize.width,
                    AVVideoHeightKey : targetSize.height,
                    AVVideoCompressionPropertiesKey: videoCompositionProps
                    ]
            }
            
            //Video input
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            input.expectsMediaDataInRealTime = true
            
            //Metadata input
            let adapter = metadataAdapter()
            
            //Frame buffer
            let sourceBufferAttributes = [
                (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
                (kCVPixelBufferWidthKey as String): Float(targetSize.width),
                (kCVPixelBufferHeightKey as String): Float(targetSize.height)] as [String : Any]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: input,
                sourcePixelBufferAttributes: sourceBufferAttributes
            )
            
            writer.add(input)
            writer.add(adapter.assetWriterInput)
            
            writer.startWriting()
            writer.startSession(atSourceTime: CMTime.zero)
            
            //Write metadata
            adapter.append(AVTimedMetadataGroup(items: [metadataForStillImageTime()], timeRange: dummyTimeRange))
            
            //Write video
            input.requestMediaDataWhenReady(on: DispatchQueue(label: "assetVideoWriterQueue", attributes: [])) {
                //Add images to video
                var frameCount: Int64 = 0
                let frameDuration = CMTimeMake(value: 1, timescale: 1) //1 frame per second
                while self.image.count != 0 {
                    if input.isReadyForMoreMediaData {
                        let lastFrameTime = CMTimeMake(value: frameCount, timescale: 1)
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        if !self.appendPixelBufferForImage(UIImage(data: self.image[0], scale:1)!, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                            print("AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
                        }
                        self.image.removeFirst()
                        frameCount += 1
                    }
                }
                
                input.markAsFinished()
                writer.finishWriting() {
                    if let e = writer.error {
                        print("cannot write: \(e)")
                    }
                }
            }
            while writer.status == .writing {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            }
            if let e = writer.error {
                print("cannot write: \(e)")
            }
        } catch {
            print("error")
        }
    }
    
    //Metadata
    fileprivate func metadataAdapter() -> AVAssetWriterInputMetadataAdaptor {
        let spec : NSDictionary = [
            kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier as NSString:
            "\(kKeySpaceQuickTimeMetadata)/\(kKeyStillImageTime)",
            kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType as NSString:
            "com.apple.metadata.datatype.int8"            ]
        
        var desc : CMFormatDescription? = nil
        CMMetadataFormatDescriptionCreateWithMetadataSpecifications(allocator: kCFAllocatorDefault, metadataType: kCMMetadataFormatType_Boxed, metadataSpecifications: [spec] as CFArray, formatDescriptionOut: &desc)
        let input = AVAssetWriterInput(mediaType: .metadata,
                                       outputSettings: nil, sourceFormatHint: desc)
        return AVAssetWriterInputMetadataAdaptor(assetWriterInput: input)
    }
    
    fileprivate func metadataFor(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyContentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
    }
    
    fileprivate func metadataForStillImageTime() -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.key = kKeyStillImageTime as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: kKeySpaceQuickTimeMetadata)
        item.value = 0 as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.int8"
        return item
    }
    
    //Fill CVPixelBuffer with AVAssetWriterInputPixelBuffer
    func appendPixelBufferForImage(_ image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = false
        
        autoreleasepool {
            let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool
            //Pointer
            let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
            let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                kCFAllocatorDefault,
                pixelBufferPool!,
                pixelBufferPointer
            )
            if let pixelBuffer = pixelBufferPointer.pointee, status == 0 {
                //Fill buffer
                fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                appendSucceeded = pixelBufferAdaptor.append(
                    pixelBuffer,
                    withPresentationTime: presentationTime
                )
                pixelBufferPointer.deinitialize(count:1)
            } else {
                NSLog("error: Failed to allocate pixel buffer from pool")
            }
            //Release memory
            pixelBufferPointer.deallocate()
        }
        return appendSucceeded
    }
    
    //Fill CVPixelBuffer with image
    func fillPixelBufferFromImage(_ image: UIImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
}

