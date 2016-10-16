//
//  ClockModel.swift
//  Cup
//
//  Created by kingslay on 15/11/3.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSJSONHelp

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
        localNotification.timeZone = TimeZone.current
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(localNotification)
        CupProvider.request(.clock(self.description)).subscribe(onNext: {_ in
        }).addDisposableTo(self.ks.disposableBag)
    }
    func removeUILocalNotification(){
        if let localNotifications = UIApplication.shared.scheduledLocalNotifications {
            for localNotification in localNotifications {
                if let fireDate = localNotification.fireDate {
                    if fireDate.ks.hour == self.hour && fireDate.ks.minute == self.minute {
                        UIApplication.shared.cancelLocalNotification(localNotification)
                        break
                    }
                }
                

            }
        }
    }
    var date: Date {
        return Date().ks.date(fromValues:[.hour:self.hour,.minute:self.minute])
    }
    public func save() {
        Query().save(self)
        if self.open {
            self.addUILocalNotification()
        } else {
            self.removeUILocalNotification()
        }
        NotificationCenter.default.post(name: .synchronizeClock, object: nil)
    }

    public func delete() {
        Query().delete(self)
        if self.open {
            self.removeUILocalNotification()
            NotificationCenter.default.post(name: .synchronizeClock, object: nil)
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
        get {
            return UserDefaults.standard.bool(forKey: "ClockModelClose")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ClockModelClose")
            if newValue {
                UIApplication.shared.cancelAllLocalNotifications()
            } else {
                _ = ClockModel.getClocks().map {
                    if $0.open {
                        $0.addUILocalNotification()
                    }
                }
            }
        }
    }
    static func primaryKeys() -> Set<String> {
        return ["hour","minute","explanation"]
    }

}
