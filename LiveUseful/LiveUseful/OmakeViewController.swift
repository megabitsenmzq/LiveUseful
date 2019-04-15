//
//  OmakeViewController.swift
//  LiveUseful
//
//  Created by 孟金羽 on 2019/02/09.
//  Copyright © 2019 Jinyu Meng. All rights reserved.
//

import UIKit

class OmakeViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func back(_ sender: Any) {
        tapticGenerator.impactOccurred()
        dismiss(animated: true, completion: {})
    }
    
    @IBAction func save(_ sender: Any) {
        tapticGenerator.impactOccurred()
        let activityViewController = UIActivityViewController(activityItems: [imageView.image!] as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
