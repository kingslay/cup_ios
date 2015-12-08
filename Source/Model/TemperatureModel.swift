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
    var open = false {
        didSet(newValue){
            if newValue {
                CupProvider.request(.Temperature(self.explanation,self.temperature)).subscribeNext {_ in
                }
            }
        }
    }
    static func addTemperature(model: TemperatureModel) {
        var array = getTemperatures()
        array.append(model)
        TemperatureModel.setObjectArray(array, forKey: "temperatureArray")
    }
  static func removeAtIndex(index: Int) {
    var array = getTemperatures()
    if array.count > index {
      array.removeAtIndex(index)
    }
    TemperatureModel.setObjectArray(array, forKey: "temperatureArray")
  }
    static func getTemperatures() -> [TemperatureModel] {
        if let array = TemperatureModel.objectArrayForKey("temperatureArray") {
            return array as! [TemperatureModel]
        }else{
            let first = TemperatureModel()
            first.explanation = "早上第一杯水温"
            first.temperature = 45
            let second = TemperatureModel()
            second.explanation = "泡咖啡"
            second.temperature = 75
            return [first,second]
        }
    }
    
}
