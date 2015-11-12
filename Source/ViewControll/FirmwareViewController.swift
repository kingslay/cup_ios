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
        self.view.backgroundColor = Colors.tableBackground
        self.updateButton.rx_tap.subscribeNext{
            let alert = UIAlertController(title: "温馨提醒", message: "你现在使用的为最新系统", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "确定", style: .Default, handler: {
                [unowned self] (UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alert.addAction(okAction)
        }.addDisposableTo(self.disposeBag)
        self.okButton.rx_tap.subscribeNext{
            NSUserDefaults.standardUserDefaults().removeObjectForKey("sharedAccount")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("sharedIdentifier")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("clockArray")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("temperatureArray")
            UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.login.instance.instantiateInitialViewController()
        }.addDisposableTo(self.disposeBag)
        self.cancelButton.rx_tap.subscribeNext{ [unowned self] in
            self.dismissViewControllerAnimated(true, completion: nil)
        }.addDisposableTo(self.disposeBag)
        
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
