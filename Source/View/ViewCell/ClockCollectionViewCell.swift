//
//  ClockCollectionViewCell.swift
//  Cup
//
//  Created by kingslay on 15/11/2.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class ClockCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var openSwitch: UISwitch!

    var datePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
