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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        SMSSDK.registerApp("c1013d64d3ff", withSecret: "528dd34e0cb571afea389ae783053243")
        staticIdentifier = " "
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // 得到当前应用的版本号
        let infoDictionary = NSBundle.mainBundle().infoDictionary
        let currentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let appVersion = userDefaults.stringForKey("appVersion")
        
        // 如果appVersion为nil说明是第一次启动；如果appVersion不等于currentAppVersion说明是更新了
        if appVersion == nil || appVersion != currentAppVersion {
            userDefaults.setValue(currentAppVersion, forKey: "appVersion")
            self.window?.rootViewController = R.nib.kSGuidanceViewController.firstView(nil, options: nil)!
        }else{
            if let dic = NSUserDefaults.standardUserDefaults().objectForKey("sharedAccount") as? [String:AnyObject] {
                staticAccount = AccountModel.toModel(dic)
                if staticIdentifier != nil {
                    self.window?.rootViewController = R.storyboard.main.instance.instantiateInitialViewController()
                }else{
                    self.window?.rootViewController = CentralViewController()
                }
            }else{
                self.window?.rootViewController = R.storyboard.sMS.instance.instantiateInitialViewController()
            }
        }
        self.window?.makeKeyAndVisible()
        UIApplication.sharedApplication().keyWindow?.tintColor = Colors.red
        UISwitch.appearance().onTintColor = Colors.red
        UISwitch.appearance().tintColor = Colors.black
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UINavigationBar.appearance().barTintColor = Colors.black
        UINavigationBar.appearance().backgroundColor = Colors.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //状态栏不透明，这样颜色比较饱满
        UINavigationBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = Colors.black
        UITabBar.appearance().translucent = false
      configureAlamofireManager()
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
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
      if application.applicationIconBadgeNumber > 0 {
        let alertController = UIAlertController(title: "亲，已到设定饮水时间咯", message: "请及时享用咯", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
      }
    }
}
func configureAlamofireManager() {
  let manager = Manager.sharedInstance
  UIImageView.af_sharedImageDownloader = ImageDownloader(sessionManager:manager)
  manager.delegate.sessionDidReceiveChallenge = { session, challenge in
    var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
    var credential: NSURLCredential?
    
    if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      disposition = NSURLSessionAuthChallengeDisposition.UseCredential
      credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
    } else {
      if challenge.previousFailureCount > 0 {
        disposition = .CancelAuthenticationChallenge
      } else {
        credential = manager.session.configuration.URLCredentialStorage?.defaultCredentialForProtectionSpace(challenge.protectionSpace)
        
        if credential != nil {
          disposition = .UseCredential
        }
      }
    }
    return (disposition, credential)
  }
}

