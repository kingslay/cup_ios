//
//  ClockModel.swift
//  Cup
//
//  Created by kingslay on 15/11/3.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSJSONHelp
import SwiftDate
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
    func addUILocalNotification(){
        let localNotification = UILocalNotification()
        var date = NSDate()
        date = date.set("hour", value: self.hour)!
        date = date.set("minute", value: self.minute)!
        localNotification.fireDate = date
        localNotification.repeatInterval = .Day
        localNotification.alertBody = "该喝水了"
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        CupProvider.request(.Clock(self.description)).subscribeNext {_ in
        }
    }
    func removeUILocalNotification(){
        if let localNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            var exit = false
            for localNotification in localNotifications {
                let fireDate = localNotification.fireDate
                
                if fireDate?.hour == self.hour && fireDate?.minute == self.minute {
                    UIApplication.sharedApplication().cancelLocalNotification(localNotification)
                    exit = true
                    break
                }
                if exit{
                    break
                }

            }
        }
    }
    
    static func addClock(model: ClockModel) {
        var array = getClocks()
        array.append(model)
        ClockModel.setObjectArray(array, forKey: "clockArray")
        if model.open {
            model.addUILocalNotification()
        }
    }
    static func getClocks() -> [ClockModel] {
        if let array = ClockModel.objectArrayForKey("clockArray") {
            return array as! [ClockModel]
        }else{
            var array: [ClockModel] = []
            for _ in 1...9 {
                let model = ClockModel()
                model.hour = 8
                model.minute = 0
                model.open = false
                array.append(model)
            }
            return array
        }
    }
}
