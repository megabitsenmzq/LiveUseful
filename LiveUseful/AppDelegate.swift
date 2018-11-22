//
//  AppDelegate.swift
//  UsefulLive
//
//  Created by Megabits on 2017/9/30.
//  Copyright © 2017 Jinyu Meng. All rights reserved.
//

import UIKit
//import AppCenter
//import AppCenterAnalytics
//import AppCenterCrashes

let livePhotoBuilder = BuildLivePhoto()
let tapticGenerator = UIImpactFeedbackGenerator(style:.light)

//Output
var origenalImage: UIImage? = nil
var croppedImage: UIImage? = nil
var sequenceImages = [Data]()

//Common
var targetSize: CGSize! //Will be set in StartVC.
let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

//Text
var tempText = ""
var tempTextCardStyle = 0
var tempTextAlign = 0
var tempMaximumFontSize: CGFloat = 35

//List
var list = [(tag: Int,text: String)]()

//QR
var tempQR = ""
var tempMultipleQR = [(image: UIImage, content: String, title: String)]()
var tempQRCardStyle = 0
var tempCurrentSize = true
var qrCardViewSmallOriginY: CGFloat = 0
var qrCardViewSmallOriginYLimit: CGFloat = 0

//Image
var tempImage:UIImage? = nil
var tempImageRound:UIImage? = nil
var tempIsRoundCorner = true
var tempIsBlur = false
var tempContentMode = true
var tempScroll = CGPoint(x: 0,y: 0)
var tempZoom: CGFloat = 1
var tempStackMode = true

//Other
var cropViewController:CropViewController?
var editViewController:EditViewController?

var isUsingLastImage = false

var isTutorialsReaded = UserDefaults.standard.bool(forKey: "tutorialsReaded") {
    didSet{
        UserDefaults.standard.set(isTutorialsReaded, forKey: "tutorialsReaded")
    }
}
var rateCount = UserDefaults.standard.integer(forKey: "rateCount") {
    didSet {
        UserDefaults.standard.set(rateCount, forKey: "rateCount")
    }
}
var isSeeItBanned = UserDefaults.standard.bool(forKey: "isSeeItBanned")
var isNotSaveList = UserDefaults.standard.bool(forKey: "isNotSaveList") {
    didSet{
        UserDefaults.standard.set(isNotSaveList, forKey: "isNotSaveList")
    }
}

//Colors
let colorRed = UIColor(red: 255/255, green: 121/255, blue: 100/255, alpha: 1)
let colorYellow = UIColor(red: 255/255, green: 188/255, blue: 103/255, alpha: 1)
let colorBlue = UIColor(red: 155/255, green: 193/255, blue: 224/255, alpha: 1)
let colorPurple = UIColor(red: 226/255, green: 128/255, blue: 228/255, alpha: 1)
let colorGray = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        MSAppCenter.start("", withServices: [MSAnalytics.self, MSCrashes.self])
        //Load list
        if UserDefaults.standard.array(forKey: "list") != nil {
            let dataToOpen = UserDefaults.standard.array(forKey: "list") as! [[String]]
            for item in dataToOpen {
                list.append((tag: Int(item[0])!, text: item[1]))
            }
        }
        
        tapticGenerator.prepare()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) {
        resetAll()
    }
    
    func resetAll() {
        //Clear all before return to CropVC
        isUsingLastImage = false
        isSeeItBanned = UserDefaults.standard.bool(forKey: "isSeeItBanned")
        sequenceImages.removeAll()
        
        //Text
        tempText = ""
        tempTextCardStyle = 0
        tempTextAlign = 0
        tempMaximumFontSize = 35
        
        //refresh list storage
        var dataToSave = [[String]]()
        if !isNotSaveList {
            for item in list {
                dataToSave.append(["\(item.tag)", item.text])
            }
            UserDefaults.standard.set(dataToSave, forKey: "list")
        } else {
            list = [(tag: Int,text: String)]()
            UserDefaults.standard.set(dataToSave, forKey: "list")
        }
        
        //QR
        tempQR = ""
        tempMultipleQR.removeAll()
        tempQRCardStyle = 0
        tempCurrentSize = true
        qrCardViewSmallOriginY = 0
        
        //Image
        tempImage = nil
        tempImageRound = nil
        tempIsRoundCorner = false
        tempIsBlur = false
        tempContentMode = true
        tempScroll = CGPoint(x: 0,y: 0)
        tempZoom = 1
        tempStackMode = true
        
        //Clear file cache
        livePhotoBuilder.clean() 
    }
}

