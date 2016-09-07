//
//  WaterModel.swift
//  Cup
//
//  Created by king on 16/9/7.
//  Copyright © 2016年 king. All rights reserved.
//

import Foundation
import KSJSONHelp
class WaterModel: NSObject,Model,Storable,PrimaryKeyProtocol {
    var year = 2016
    var month = 01
    var weekOfYear = 01
    var day = 01
    var hour = 08
    var minute = 0
    var second = 0
    var amount = 0
    override required init() {
        super.init()
    }
    static func primaryKeys() -> Set<String> {
        return ["year","month","day","hour","minute","second"]
    }
    static func save(date: NSDate,amount: Int) {
        let model = WaterModel()
        model.year = date.year
        model.month = date.month
        model.weekOfYear = date.weekOfYear
        model.day = date.day
        model.hour = date.hour
        model.minute = date.minute
        model.second = date.second
        model.amount = amount
        model.save()
    }

}