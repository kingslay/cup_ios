//
//  ClockTableViewCell.swift
//  Cup
//
//  Created by king on 16/9/3.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
class ClockTableViewCell: UITableViewCell {
    @IBOutlet weak var timeTextField: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var openSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
