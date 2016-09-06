//
//  WaterHistoryTableViewCell.swift
//  Cup
//
//  Created by king on 16/9/5.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

class WaterHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wateLabel: UILabel!
    @IBOutlet weak var wateRateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
