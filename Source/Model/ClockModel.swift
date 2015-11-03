//
//  ClockModel.swift
//  Cup
//
//  Created by kingslay on 15/11/3.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSJSONHelp
class ClockModel: NSObject {
    var hour:Int
    var minute :Int
    var open = true
    override var description: String { return String(format: "%02d:%02d", self.hour,self.minute) }
    override init(){
        self.hour = 0
        self.minute = 0
    }
    init(hour:Int,minute:Int,open:Bool = true) {
        self.hour = hour
        self.minute = minute
        self.open = open
    }
    
}
