//
//  FirmwareViewController.swift
//  Cup
//
//  Created by king on 15/11/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import RxSwift
class FirmwareViewController: UIViewController {
    let disposeBag = DisposeBag()

    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.background
        self.updateButton.rx_tap.subscribeNext{ [unowned self] in
            let alert = UIAlertController(title: "温馨提醒", message: "你现在使用的为最新系统", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "确定", style: .Default, handler: {
                [unowned self] (UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }.addDisposableTo(self.disposeBag)
        self.okButton.rx_tap.subscribeNext{ [unowned self] in
            NSUserDefaults.standardUserDefaults().removeObjectForKey("sharedAccount")
            staticIdentifier = nil
            if let vcs = self.tabBarController?.viewControllers where vcs.count > 1, let navigationController = vcs[1] as? UINavigationController, let cupViewController = navigationController.topViewController as? CupViewController, let peripheral = cupViewController.peripheral  {
                cupViewController.central.cancelPeripheralConnection(peripheral)
            }
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            NSUserDefaults.standardUserDefaults().removeObjectForKey("ClockModelClose")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("clockArray")
            TemperatureModel.delete(dic: [:])
            UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.sMS.initialViewController()
        }.addDisposableTo(self.disposeBag)
        self.cancelButton.rx_tap.subscribeNext{ [unowned self] in
            self.dismissViewControllerAnimated(true, completion: nil)
        }.addDisposableTo(self.disposeBag)
        
    }
}
