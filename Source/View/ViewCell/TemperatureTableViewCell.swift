//
//  TemperatureTableViewCell.swift
//  Cup
//
//  Created by kingslay on 15/11/10.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class TemperatureTableViewCell: UITableViewCell {

    @IBOutlet weak var explanationLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var openSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
