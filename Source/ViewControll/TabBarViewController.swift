//
//  TabBarViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/2.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cup = UINavigationController.init(rootViewController: R.nib.cupViewController.firstView(nil, options: nil)!)
        cup.tabBarItem.title = "水杯"
        let clock = UINavigationController.init(rootViewController: R.nib.clockCollectionViewController.firstView(nil, options: nil)!)
        clock.tabBarItem.title = "闹钟"
        
        self.viewControllers = [cup,clock]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
