//
//  AddListViewController.swift
//  LiveUseful
//
//  Created by Megabits on 2018/2/20.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

class AddListViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var snapshotView: UIView!
    @IBOutlet var toolsBackgroundView: UIView!
    @IBOutlet var textCardView: UIVisualEffectView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var saveSwitch: UISwitch!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var cardStyleButton: UIButton!
    @IBOutlet var backgroundBlur: UIVisualEffectView!
    @IBOutlet var listTable: UITableView!
    @IBOutlet var itemCount: UILabel!
    @IBOutlet var tipView: UIView!
    
    var isShowTools = true
    var cardStyle = 0 {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                switch self.cardStyle {
                case 0:
                    self.textCardView.effect = UIBlurEffect(style: .extraLight)
                    self.backgroundBlur.effect = .none
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Extra light", comment: "Extra light")
                case 1:
                    self.textCardView.effect = UIBlurEffect(style: .light)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Light", comment: "Light")
                case 2:
                    self.textCardView.effect = UIBlurEffect(style: .dark)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Dark", comment: "Dark")
                case 3:
                    self.textCardView.effect = .none
                    self.backgroundBlur.effect = UIBlurEffect(style: .regular)
                    self.cardStyleButton.accessibilityValue = NSLocalizedString("Background blur", comment: "Background blur")
                default:
                    self.cardStyle = 0
                }
                tempTextCardStyle = self.cardStyle
            })
            listTable.reloadData()
        }
    }
    
    var toolsTempOriginY: CGFloat = 0
    var maxItemCount = 0
    
    var isMovingItem = false {
        didSet {
            okButton.isEnabled = !isMovingItem
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.previewView.frame.origin = CGPoint(x:0, y:self.view.frame.height)
        })
        showAndHideTools({
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {})
        })
    }
    
    @IBAction func ok(_ sender: Any) {
        
        listTable.reloadData()
        
        let buildingView = UIVisualEffectView(effect: .none)
        let buildingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        buildingIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        buildingIndicator.center = view.center
        buildingIndicator.startAnimating()
        buildingIndicator.alpha = 0
        buildingView.contentView.addSubview(buildingIndicator)
        buildingView.frame = CGRect(x:0, y:0, width:view.frame.width, height:view.frame.height)
        view.addSubview(buildingView)
        
        //Screenshot
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
        self.snapshotView.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: targetSize), afterScreenUpdates: true)
        let aImage = UIGraphicsGetImageFromCurrentImageContext()!.jpegData(compressionQuality: 1)!
        sequenceImages.append(aImage)
        UIGraphicsEndImageContext()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            buildingView.effect = UIBlurEffect(style: .light)
            buildingIndicator.alpha = 1
            
            self.previewView.alpha = 0
            self.toolsBackgroundView.alpha = 0
            self.backgroundBlur.effect = .none
        }, completion: { (finished: Bool) in
            tapticGenerator.impactOccurred()
            self.performSegue(withIdentifier: "toBuildFromList", sender: self)
        })
    }
    
    @IBAction func changeCardStyle(_ sender: Any) {
        tapticGenerator.impactOccurred()
        cardStyle += 1
    }
    
    @IBAction func toList(_ sender: Any) {
        tapticGenerator.impactOccurred()
        self.presentingViewController?.viewDidLayoutSubviews()
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func addItem(_ sender: Any) {
        tapticGenerator.impactOccurred()
        
        let alertController = UIAlertController(title: NSLocalizedString("Add New Item", comment: "Add New Item"), message: "", preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField!) -> Void in
            textField.autocapitalizationType = .sentences
            textField.autocorrectionType = .default
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: {
            action in
            let itemText = alertController.textFields!.first!.text!
            if itemText.trimmingCharacters(in: CharacterSet.whitespaces) != "" {
                list.append((tag: 0,text: itemText))
                self.listTable.reloadData()
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeSave(_ sender: Any) {
        isNotSaveList = !saveSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTable.delegate = self
        listTable.dataSource = self
        
        saveSwitch.isOn = !UserDefaults.standard.bool(forKey: "isNotSaveList")
        
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: addButton)
        
        let longPress =  UILongPressGestureRecognizer(target:self, action:#selector(tableviewCellLongPressed))
        longPress.minimumPressDuration = 0.3
        longPress.delegate = listTable as! UIGestureRecognizerDelegate?
        listTable.addGestureRecognizer(longPress)
        
        imageView.image = croppedImage
        backgroundBlur.effect = .none
        
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        okButton.accessibilityLabel = NSLocalizedString("OK", comment: "OK")
        
        cardStyleButton.accessibilityLabel = NSLocalizedString("Card Style", comment: "Card Style")
        
        if tempText != "" {
            okButton.isEnabled = true
        }
        
        cardStyle = tempTextCardStyle
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maxItemCount = Int(listTable.frame.height / 35)
        itemCount.text = "\(list.count)/\(maxItemCount)"
        listTable.reloadData()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func accessibilityPerformEscape() -> Bool {
        cancel(self)
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list.count > 0 { //item count limit
            okButton.isEnabled = true
            if list.count > maxItemCount - 1 {
                addButton.isEnabled = false
            } else {
                addButton.isEnabled = true
            }
        } else {
            okButton.isEnabled = false
        }
        itemCount.text = "\(list.count)/\(maxItemCount)"
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        
        cell.tagColor = list[indexPath.row].tag
        cell.Label.text = list[indexPath.row].text
        
        cell.backgroundColor = .clear
        if cardStyle == 0 {
            cell.Label.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        } else {
            cell.Label.textColor = .white
        }
        
        cell.accessibilityLabel = cell.colorTag.accessibilityLabel! + "," + cell.Label.text!
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { //Swipe left delete
        if editingStyle == UITableViewCell.EditingStyle.delete {
            tapticGenerator.impactOccurred()
            list.remove(at: indexPath.row)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){ //Tap to change color
        if !isMovingItem { //Refresh at moving will make a shadow of the item.
            tapticGenerator.impactOccurred()
            
            list[indexPath.row].tag += 1
            if list[indexPath.row].tag == 5 {
                list[indexPath.row].tag = 0
            }
            tableView.reloadData()
        }
    }
    
    @objc func tableviewCellLongPressed(gestureRecognizer:UILongPressGestureRecognizer){
        let longPress = gestureRecognizer as UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in:listTable)
        let indexPath = listTable.indexPathForRow(at: locationInView)
        
        struct My {static var cellSnapshot : UIView? = nil}
        struct Path {static var initialIndexPath : IndexPath? = nil}
        
        func snapshopOfCell(inputView: UIView) -> UIView {
            UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
            inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
            UIGraphicsEndImageContext()
            let cellSnapshot : UIView = UIImageView(image: image)
            cellSnapshot.layer.masksToBounds = false
            cellSnapshot.layer.cornerRadius = 0.0
            cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
            cellSnapshot.layer.shadowRadius = 3.0
            cellSnapshot.layer.shadowOpacity = 0.2
            return cellSnapshot
        }
        
        switch state {
        case UIGestureRecognizer.State.began:
            if indexPath != nil {
                if let cell = listTable.cellForRow(at: indexPath!) as UITableViewCell? {
                    isMovingItem = true
                    tapticGenerator.impactOccurred()
                    Path.initialIndexPath = indexPath
                    My.cellSnapshot  = snapshopOfCell(inputView: cell)
                    var center = cell.center
                    My.cellSnapshot!.center = center
                    
                    listTable.addSubview(My.cellSnapshot!)
                    cell.isHidden = true
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        center.y = locationInView.y
                        My.cellSnapshot!.center = center
                        My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }, completion: { (finished) -> Void in
                    })
                }
            }
        case UIGestureRecognizer.State.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                if (indexPath != nil) && (indexPath != Path.initialIndexPath) {
                    //Actual change data
                    listTable.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    list.swapAt(indexPath!.row, Path.initialIndexPath!.row)
                    Path.initialIndexPath = indexPath
                }
            }
            
        default:
            if My.cellSnapshot != nil {
                isMovingItem = false
                tapticGenerator.impactOccurred()
                if let cell = listTable.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell? {
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        My.cellSnapshot!.center = cell.center
                        My.cellSnapshot!.transform = .identity
                    }, completion: { (finished) -> Void in
                        cell.isHidden = false
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    })
                } else {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            }
        }
    }
    
    func showAndHideTools(_ afterAnimation: @escaping () -> ()) {
        if isShowTools {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                self.toolsBackgroundView.frame.origin = CGPoint(x:0, y:0 - self.toolsBackgroundView.frame.height)
                self.tipView.alpha = 0
            }, completion: { (finished: Bool) in
                self.isShowTools = false
                afterAnimation()
            })
        } else {
            
        }
    }

}
