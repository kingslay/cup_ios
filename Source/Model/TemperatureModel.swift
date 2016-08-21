//
//  TemperatureModel.swift
//  Cup
//
//  Created by kingslay on 15/11/10.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSJSONHelp
class TemperatureModel: NSObject,Model,Storable,PrimaryKeyProtocol {
    override required init() {
        super.init()
    }
    var explanation:String = ""
    var temperature:Int = 50
    static func primaryKeys() -> Set<String> {
        return ["explanation","temperature"]
    }
    var open = false {
        didSet(newValue){
            if newValue {
                CupProvider.request(.Temperature(self.explanation,self.temperature)).subscribeNext {_ in
                    }.addDisposableTo(self.ks.disposableBag)
            }
        }
    }
    static func getTemperatures() -> [TemperatureModel] {
        if let array = TemperatureModel.fetch(nil) where array.count > 0 {
            return array
        }else{
            let first = TemperatureModel()
            first.explanation = "早上的第一杯水"
            first.temperature = 45
            first.save()
            let second = TemperatureModel()
            second.explanation = "工作喝水"
            second.temperature = 55
            second.save()
            let third = TemperatureModel()
            third.explanation = "运动后喝水"
            third.temperature = 50
            third.save()
            return [first,second,third]
        }
    }
    
    
}
