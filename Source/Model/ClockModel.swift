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
    }
    func removeUILocalNotification(){
        if let localNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for localNotification in localNotifications {
                let fireDate = localNotification.fireDate
                if fireDate?.hour == self.hour && fireDate?.minute == self.minute {
                    UIApplication.sharedApplication().cancelLocalNotification(localNotification)
                    break
                }
            }
        }
    }
}
