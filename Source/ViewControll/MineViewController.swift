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
    var datas :[[(UIImage?,String)]]!
    lazy var navigationAccessoryView : NavigationAccessoryView = {
        let naview = NavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44.0))
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_exit(), style: .plain, target: self, action: #selector(exitAccount))
        self.tableView.backgroundColor = Colors.background
        self.tableView.register(R.nib.mineTableViewCell)
        self.tableView.rowHeight = 51
        datas = [[(R.image.icon_modify(),"个人资料修改")],
//                (R.image.icon_plan(),"饮水计划(ml)")],
                 [
//                    (R.image.icon_account(),"帐号绑定"),
//                    (R.image.icon_warn(),"提醒设置"),
                    (R.image.icon_pairing(),"配对信息"),
                    (R.image.icon_nickname(),"固件升级"),
                    (R.image.icon_about(),"关于")]]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    func exitAccount() {
        let alertController = UIAlertController(title: nil, message: "确认要退出当前账号吗", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "继续", style: UIAlertActionStyle.default,handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "退出", style: UIAlertActionStyle.default) {
            [unowned self] (action: UIAlertAction!) -> Void in
            UserDefaults.standard.removeObject(forKey: "sharedAccount")
            staticIdentifier = nil
            if let vcs = self.tabBarController?.viewControllers , vcs.count > 1, let navigationController = vcs[1] as? UINavigationController, let cupViewController = navigationController.topViewController as? CupViewController, let peripheral = cupViewController.peripheral  {
                cupViewController.central.cancelPeripheralConnection(peripheral)
            }
            UIApplication.shared.cancelAllLocalNotifications()
            UserDefaults.standard.removeObject(forKey: "ClockModelClose")
            UserDefaults.standard.removeObject(forKey: "clockArray")
            TemperatureModel.delete(dic: [:])
            UIApplication.shared.keyWindow!.rootViewController = R.storyboard.sMS.instantiateInitialViewController()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
extension MineViewController {
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.mineTableViewCell)!
        let (image,title) = datas[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.iconImageView.image = image
        cell.titleLabel.text = title
        cell.headerImageView.isHidden = true
        cell.valueTextField.isHidden = true
        cell.accessoryType = .disclosureIndicator
        if (indexPath as NSIndexPath).section == 0 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.headerImageView.isHidden = false
                if let str = staticAccount?.avatar,let url = URL(string: str) {
                    cell.headerImageView!.af_setImage(withURL:url, placeholderImage: R.image.默认头像(),filter: AspectScaledToFillSizeCircleFilter(size: CGSize(width: 41, height: 41)))
                }
            case 1:
                cell.valueTextField.isHidden = false
                if let value = staticAccount?.waterplan {
                    cell.valueTextField.text = "\(value)"
                }
            default:
                break
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else{
            return 25
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row) {
        case (0,0):
            self.navigationController?.ks.pushViewController(AccountViewController())
        case (0,1):
            let vc = R.nib.waterplanViewController.firstView(owner: nil, options: nil)!
            self.navigationController?.ks.pushViewController(vc)
//        case(1,0):
//            let vc = R.nib.accoutBindViewController.firstView(owner: nil, options: nil)!
//            vc.phoneLabel.text = staticAccount?.phone
//            self.navigationController?.ks.pushViewController(vc)
//        case(1,1):
//            let vc = R.nib.pushSettingViewController.firstView(owner: nil, options: nil)!
//            self.navigationController?.ks.pushViewController(vc)
        case(1,0):
            let vc = R.nib.firmwareViewController.firstView(owner: nil, options: nil)!
            vc.serialLabel.text = "序列号: " + (staticIdentifier ?? "")
            self.navigationController?.ks.pushViewController(vc)
        case(1,1):
            let vc = R.nib.firmwareViewController.firstView(owner: nil, options: nil)!
            vc.serialLabel.text = "序列号: " + (staticIdentifier ?? "")
            vc.updateButton.isHidden = false
            self.navigationController?.ks.pushViewController(vc)
        case(1,2):
            self.navigationController?.ks.pushViewController(R.nib.aboutUsViewController.firstView(owner: nil, options: nil)!)
        default:
            break;
        }
    }
    
}
