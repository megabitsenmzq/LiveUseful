//
//  ListTableViewCell.swift
//  PomoNow
//
//  Created by Megabits on 2018/2/20.
//  Copyright © 2018 Jinyu Meng. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var colorTag: UIView!
    
    var tagColor = 0 {
        didSet {
            switch tagColor {
            case 0:
                colorTag.backgroundColor = colorRed
                colorTag.accessibilityLabel = NSLocalizedString("Red color tag",comment:"Red color tag")
            case 1:
                colorTag.backgroundColor = colorYellow
                colorTag.accessibilityLabel = NSLocalizedString("Yellow color tag",comment:"Yellow color tag")
            case 2:
                colorTag.backgroundColor = colorBlue
                colorTag.accessibilityLabel = NSLocalizedString("Blue color tag",comment:"Blue color tag")
            case 3:
                colorTag.backgroundColor = colorPurple
                colorTag.accessibilityLabel = NSLocalizedString("Purple color tag",comment:"Purple color tag")
            case 4:
                colorTag.backgroundColor = colorGray
                colorTag.accessibilityLabel = NSLocalizedString("Gray color tag",comment:"Gray color tag")
            default:break
            }
        }
    }
}
