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
        localNotification.fireDate = self.date
        localNotification.repeatInterval = .day
        localNotification.alertBody = explanation
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.timeZone = TimeZone.autoupdatingCurrent
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(localNotification)
        CupProvider.request(.clock(self.description)).subscribeNext {_ in
        }.addDisposableTo(self.ks.disposableBag)
    }
    func removeUILocalNotification(){
        if let localNotifications = UIApplication.shared.scheduledLocalNotifications {
            for localNotification in localNotifications {
                if let fireDate = localNotification.fireDate {
                    if fireDate.hour == self.hour && fireDate.minute == self.minute {
                        UIApplication.shared.cancelLocalNotification(localNotification)
                        break
                    }
                }
                

            }
        }
    }
    var date: Date {
        var dateComponents = Date().ks.dateComponents
        dateComponents.hour = self.hour
        dateComponents.minute = self.minute
        return NSCalendar.autoupdatingCurrent.date(from:dateComponents)!
    }

    static func addClock(_ model: ClockModel) {
        model.save()
        if model.open {
            model.addUILocalNotification()
        }
    }
    static func getClocks() -> [ClockModel] {
        if let array = ClockModel.fetch(nil) , array.count > 0 {
            return array
        } else {
            return []
        }
    }
    static var close: Bool {
        get{
            return UserDefaults.standard.bool(forKey: "ClockModelClose")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "ClockModelClose")
        }
    }
    static func primaryKeys() -> Set<String> {
        return ["hour","minute","explanation"]
    }

}
