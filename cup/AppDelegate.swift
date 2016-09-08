//
//  AppDelegate.swift
//  Cup
//
//  Created by king on 15/10/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
import Alamofire
import AlamofireImage
import KSJSONHelp
import MonkeyKing

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Database.driver = SQLiteDriver()
        Bugly.startWithAppId("971cdd61af")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // 得到当前应用的版本号
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var appVersion = userDefaults.stringForKey("appVersion")
        // 如果appVersion为nil说明是第一次启动；如果appVersion不等于currentAppVersion说明是更新了
        if appVersion == nil {
            userDefaults.setValue(currentAppVersion, forKey: "appVersion")
            self.window?.rootViewController = R.nib.kSGuidanceViewController.firstView(owner: nil, options: nil)!
        }else{
            if let dic = NSUserDefaults.standardUserDefaults().objectForKey("sharedAccount") as? [String:AnyObject] {
                staticAccount = AccountModel(from: dic)
              self.window?.rootViewController = R.storyboard.main.initialViewController()
            }else{
                self.window?.rootViewController = R.storyboard.sMS.initialViewController()
            }
        }
        self.window?.makeKeyAndVisible()
        UIApplication.sharedApplication().keyWindow?.tintColor = Colors.red
        UISegmentedControl.appearance().tintColor = Colors.red
        UIBarButtonItem.appearance().tintColor = Colors.background
        UINavigationBar.appearance()
        UISwitch.appearance().onTintColor = Colors.red
        UISwitch.appearance().tintColor = Colors.black
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UINavigationBar.appearance().tintColor = Colors.background
        UINavigationBar.appearance().barTintColor = Colors.red
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.background]
        //状态栏不透明，这样颜色比较饱满
        UINavigationBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = Colors.white
        UITabBar.appearance().tintColor = Colors.red
        UITabBar.appearance().translucent = false
        configureAlamofireManager()
        SMSSDK.registerApp("16ece37bd2580", withSecret: "3e403d5017a8b968bc86b461f1f9d543")
        MonkeyKing.registerAccount(.WeChat(appID: "wxfc361b137c76f916",appKey: nil))
        //appKey DDbYXy3a8zJH2aeA
        MonkeyKing.registerAccount(.QQ(appID: "1105615474"))
        MonkeyKing.registerAccount(.Weibo(appID: "3083484688", appKey: "cb5afe0602f54f3fd82aea937020c1c2", redirectURL: "wxfc361b137c76f916"))
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if MonkeyKing.handleOpenURL(url) {
            return true
        }
        return false
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
      if application.applicationIconBadgeNumber > 0 {
        let alertController = UIAlertController(title: "亲! 已到设定饮水时间咯!", message: "请及时享用哦。", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
      }
    }
}
func configureAlamofireManager() {
    UIImageView.af_sharedImageDownloader = ImageDownloader(sessionManager:CupMoya.sharedManager())
   
}

