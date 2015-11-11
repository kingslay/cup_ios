//
//  MineViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import AlamofireImage
class MineViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.tableView.registerNib(R.nib.mineTableViewCell)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return 4
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.accessoryType = .DisclosureIndicator
        if indexPath.section == 0 {
            if let str = staticAccount?.avatar,url = NSURL(string: str) {
                cell.imageView!.af_setImageWithURL(url, placeholderImage: R.image.mine_photo,filter: AspectScaledToFillSizeCircleFilter(size: CGSizeMake(36, 36)))
            }else{
                cell.imageView!.image = R.image.mine_photo
            }
            cell.textLabel?.text = "个人信息"
            return cell
            
        }
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "关于我们"
        case 1:
            cell.textLabel?.text = "已配对信息"
        case 2:
            cell.textLabel?.text = "恢复出厂设置"
        case 3:
            cell.textLabel?.text = "固件升级"
        default:
            break
        }
        
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else {
            return 45
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }else{
            return 10
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.navigationController?.ks_pushViewController(AccountViewController())
        }else{
            if indexPath.row == 0 {
                self.navigationController?.ks_pushViewController(R.nib.aboutUsViewController.firstView(nil, options: nil)!)
                return
            }
            let vc = R.nib.firmwareViewController.firstView(nil, options: nil)!
            if indexPath.row == 2 {
                vc.okButton.hidden = false
                vc.cancelButton.hidden = false
            }else if indexPath.row == 3{
                vc.updateButton.hidden = false
                vc.updateLabel.hidden = false
            }
            self.navigationController?.ks_pushViewController(vc)
        }
    }
    
}
