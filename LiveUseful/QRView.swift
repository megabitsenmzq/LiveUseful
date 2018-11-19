//
//  QRView.swift
//  LiveUseful
//
//  Created by Megabits on 2018/6/16.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

protocol QRViewDelegate: class {
    func removeItem(id: Int)
    func editItem(id: Int)
}

class QRView: UIView {
    var qrImage: UIImage? = nil {
        didSet{
            qrImageView.image = qrImage
        }
    }
    var id = 0 {
        didSet{
            tapToEditLabel.text = NSLocalizedString("Edit", comment: "Edit") + ",ID\(id)"
            removeButton.accessibilityLabel = NSLocalizedString("Remove", comment: "Remove") + ",ID\(id)"
        }
    }
    
    private var tapToEditLabel = UILabel()
    private var bgImageView = UIImageView(frame: CGRect.zero)
    private var qrImageView = UIImageView(frame: CGRect.zero)
    private var removeButton = UIButton(frame: CGRect.zero)
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    weak var delegate: QRViewDelegate?
    
    init(frame: CGRect, qrImage: UIImage) {
        super.init(frame: frame)
        self.qrImage = qrImage
        
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = true
        shouldGroupAccessibilityChildren = true

        let squareLayout = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 1)
        addConstraint(squareLayout)
        
        //Focus for VoiceOver
        tapToEditLabel.text = NSLocalizedString("Edit", comment: "Edit") + ",ID\(id)"
        addSubview(tapToEditLabel)
        
        //White square
        bgImageView.backgroundColor = .clear
        bgImageView.image = #imageLiteral(resourceName: "QRBackground")
        bgImageView.contentMode = .scaleAspectFill
        addSubview(bgImageView)
        
        //QR image
        qrImageView.image = qrImage
        qrImageView.isUserInteractionEnabled = true
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(edit))
        qrImageView.addGestureRecognizer(tapGestureRecognizer)
        addSubview(qrImageView)
        
        //Remove button
        removeButton.setImage(#imageLiteral(resourceName: "Remove"), for: .normal)
        removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        removeButton.accessibilityLabel = NSLocalizedString("Remove", comment: "Remove") + ",ID\(id)"
        addSubview(removeButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        tapToEditLabel.frame = CGRect(x: 30, y: 30, width: frame.width - 60, height: frame.width - 60)
        bgImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        qrImageView.frame = CGRect(x: frame.width * 0.125, y: frame.width * 0.125, width: frame.width * 0.75, height: frame.width * 0.75)
        removeButton.frame = CGRect(x: frame.width * 0.77, y: frame.width * 0.03, width: frame.width * 0.2, height: frame.width * 0.2)
    }
    
    @objc func edit() {
        self.delegate?.editItem(id: self.id)
    }
    
    @objc func remove() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 0
        }, completion: { (finished: Bool) in
            self.delegate?.removeItem(id: self.id)
        })
    }
}
