//
//  TemperatureModel.swift
//  Cup
//
//  Created by kingslay on 15/11/10.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class TemperatureModel: NSObject {
    var explanation:String = ""
    var temperature:Int = 50
    var open = false
    static func addTemperature(model: TemperatureModel) {
        var array = getTemperatures()
        array.append(model)
        TemperatureModel.setObjectArray(array, forKey: "temperatureArray")
    }
    static func getTemperatures() -> [TemperatureModel] {
        if let array = TemperatureModel.objectArrayForKey("temperatureArray") {
            return array as! [TemperatureModel]
        }else{
            return []
        }
    }
}
