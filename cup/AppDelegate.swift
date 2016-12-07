//
//  AppDelegate.swift
//  Cup
//
//  Created by king on 15/10/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSJSONHelp
import MonkeyKing
import AlamofireImage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Database.driver = SQLiteDriver()
        Bugly.start(withAppId: "971cdd61af")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // 得到当前应用的版本号
        let infoDictionary = Bundle.main.infoDictionary
        let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        let userDefaults = UserDefaults.standard
        let appVersion = userDefaults.string(forKey: "appVersion")
        // 如果appVersion为nil说明是第一次启动；如果appVersion不等于currentAppVersion说明是更新了
        if appVersion == nil {
            userDefaults.setValue(currentAppVersion, forKey: "appVersion")
            self.window?.rootViewController = R.nib.kSGuidanceViewController.firstView(owner: nil, options: nil)!
        }else{
            if let dic = UserDefaults.standard.object(forKey: "sharedAccount") as? [String:AnyObject] {
                staticAccount = AccountModel(from: dic)
              self.window?.rootViewController = R.storyboard.main.instantiateInitialViewController()
            }else{
                self.window?.rootViewController = R.storyboard.sMS.instantiateInitialViewController()
            }
        }
        self.window?.makeKeyAndVisible()
        UIApplication.shared.keyWindow?.tintColor = Colors.red
        UISegmentedControl.appearance().tintColor = Colors.white
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.red], for: .selected)
        UIBarButtonItem.appearance().tintColor = Colors.background
        UINavigationBar.appearance()
        UISwitch.appearance().onTintColor = Colors.red
        UISwitch.appearance().tintColor = Colors.black
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().tintColor = Colors.background
        UINavigationBar.appearance().barTintColor = Colors.red
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Colors.background]
        //状态栏不透明，这样颜色比较饱满
        UINavigationBar.appearance().isTranslucent = false
        UITabBar.appearance().barTintColor = Colors.white
        UITabBar.appearance().tintColor = Colors.red
        UITabBar.appearance().isTranslucent = false
        //AppSecret：a815bf4b3277e5d3c0e6df1d0958e3ab
        MonkeyKing.registerAccount(.weChat(appID: "wxe96808efbc07344c",appKey: nil))
        //appKey DDbYXy3a8zJH2aeA
        MonkeyKing.registerAccount(.qq(appID: "1105615474"))
        MonkeyKing.registerAccount(.weibo(appID: "3083484688", appKey: "cb5afe0602f54f3fd82aea937020c1c2", redirectURL: "wxfc361b137c76f916"))
        UIImageView.af_sharedImageDownloader = ImageDownloader(sessionManager:CupMoya.sharedManager())
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if MonkeyKing.handleOpenURL(url) {
            return true
        }
        return false
    }
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
      if application.applicationIconBadgeNumber > 0 {
        let alertController = UIAlertController(title: "亲! 已到设定饮水时间咯!", message: notification.alertBody, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okAction)
        window?.rootViewController?.present(alertController, animated: true, completion: nil)
      }
    }
}

