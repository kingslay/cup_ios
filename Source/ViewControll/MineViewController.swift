//
//  MineViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import KSSwiftExtension
class MineViewController: UITableViewController {
    var datas :[[(UIImage?,String,String?)]]!
    lazy var navigationAccessoryView : NavigationAccessoryView = {
        let naview = NavigationAccessoryView(frame: CGRectMake(0, 0, self.view.frame.width, 44.0))
        naview.doneButton.target = self
        naview.doneButton.action = #selector(navigationDone)
        return naview
    }()
    func navigationDone() {
        tableView?.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.background
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_exit(), style: .Plain, target: self, action: #selector(exitAccount))
        self.tableView.backgroundColor = Colors.background
        self.tableView.registerNib(R.nib.mineTableViewCell)
        initData()
        self.tableView.rowHeight = 51
        self.tableView.reloadData()
    }
    func exitAccount() {
        let alertController = UIAlertController(title: nil, message: "确认要退出当前账号吗", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "继续", style: UIAlertActionStyle.Default,handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "退出", style: UIAlertActionStyle.Default) {
            [unowned self] (action: UIAlertAction!) -> Void in
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
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    func initData(){
        datas = [[(R.image.icon_modify(),"个人资料修改",staticAccount?.avatar),
            (R.image.icon_plan(),"饮水计划(ml)",staticAccount?.waterplan != nil ? "\(staticAccount!.waterplan!)" : nil)],
                 [(R.image.icon_account(),"帐号绑定",nil),
                    (R.image.icon_warn(),"提醒设置",nil),
                    (R.image.icon_pairing(),"配对信息",nil),
                    (R.image.icon_nickname(),"固件升级",nil),
                    (R.image.icon_about(),"关于",nil)]]
    }

}
extension MineViewController {
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return datas.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.mineTableViewCell)!
        let (image,title,value) = datas[indexPath.section][indexPath.row]
        cell.iconImageView.image = image
        cell.titleLabel.text = title
        cell.headerImageView.hidden = true
        cell.valueTextField.hidden = true;
        cell.accessoryType = .DisclosureIndicator
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.headerImageView.hidden = false
                if let str = value,url = NSURL(string: str) {
                    cell.headerImageView!.af_setImageWithURL(url, placeholderImage: R.image.label_icon_Personal_initial(),filter: AspectScaledToFillSizeCircleFilter(size: CGSizeMake(41, 41)))
                }
            case 1:
                cell.valueTextField.placeholder = ""
            default:
                break
            }
        } else {
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else{
            return 25
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            self.navigationController?.ks.pushViewController(AccountViewController())
        case (0,1):
            let vc = R.nib.waterplanViewController.firstView(owner: nil, options: nil)!
            self.navigationController?.ks.pushViewController(vc)
        case(1,0):
            let vc = R.nib.accoutBindViewController.firstView(owner: nil, options: nil)!
            vc.phoneLabel.text = staticAccount?.phone
            self.navigationController?.ks.pushViewController(vc)
        case(1,1):
            let vc = R.nib.pushSettingViewController.firstView(owner: nil, options: nil)!
            self.navigationController?.ks.pushViewController(vc)
        case(1,2):
            let vc = R.nib.firmwareViewController.firstView(owner: nil, options: nil)!
            vc.serialLabel.text = "序列号: " + (staticIdentifier ?? "")
            self.navigationController?.ks.pushViewController(vc)
        case(1,3):
            let vc = R.nib.firmwareViewController.firstView(owner: nil, options: nil)!
            vc.serialLabel.text = "序列号: " + (staticIdentifier ?? "")
            vc.updateButton.hidden = false
            self.navigationController?.ks.pushViewController(vc)
        case(1,4):
            self.navigationController?.ks.pushViewController(R.nib.aboutUsViewController.firstView(owner: nil, options: nil)!)
        default:
            break;
        }
    }
    
}
