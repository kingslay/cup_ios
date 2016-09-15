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
class ClockModel: NSObject,Model,Storable,PrimaryKeyProtocol {
    var explanation:String = ""
    var hour:Int
    var minute :Int
    var open = true
    override var description: String { return String(format: "%02d:%02d", self.hour,self.minute) }
    override required init(){
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
        let components = NSDate().components
        components.timeZone = NSTimeZone.localTimeZone()
        components.hour = self.hour
        components.minute = self.minute
        localNotification.fireDate = components.date
        localNotification.repeatInterval = .Day
        localNotification.alertBody = explanation
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.timeZone = NSTimeZone.localTimeZone()
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        CupProvider.request(.Clock(self.description)).subscribeNext {_ in
        }.addDisposableTo(self.ks.disposableBag)
    }
    func removeUILocalNotification(){
        if let localNotifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            for localNotification in localNotifications {
                if let fireDate = localNotification.fireDate {
                    let components = fireDate.components(inRegion: Region())
                    if components.hour == self.hour && components.minute == self.minute {
                        UIApplication.sharedApplication().cancelLocalNotification(localNotification)
                        break
                    }
                }
                

            }
        }
    }
    
    static func addClock(model: ClockModel) {
        model.save()
        if model.open {
            model.addUILocalNotification()
        }
    }
    static func getClocks() -> [ClockModel] {
        if let array = ClockModel.fetch(nil) where array.count > 0 {
            return array
        } else {
            return []
        }
    }
    static var close: Bool {
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey("ClockModelClose")
        }
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "ClockModelClose")
        }
    }
    static func primaryKeys() -> Set<String> {
        return ["hour","minute","explanation"]
    }

}
