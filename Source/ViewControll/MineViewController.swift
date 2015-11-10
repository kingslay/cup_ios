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
            return 5
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.mineTableViewCell.reuseIdentifier, forIndexPath: indexPath)
            if let str = staticAccount?.avatar,url = NSURL(string: str) {
                cell?.headerImageView.af_setImageWithURL(url, placeholderImage: R.image.mine_photo,filter: AspectScaledToFillSizeFilter(size: CGSizeMake(62, 62)))
            }else{
                cell?.headerImageView.image = R.image.mine_photo
            }
            cell?.nickNameLabel.text = "个人信息"
            return cell!
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "1"
            case 1:
                cell.textLabel?.text = "2"
            case 2:
                cell.textLabel?.text = "3"
            case 3:
                cell.textLabel?.text = "4"
            case 4:
                cell.textLabel?.text = "5"
            default:
                break
            }
            
            return cell
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70
        } else {
            return 40
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }else{
            return 40
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.ks_pushViewController(AccountViewController())
        }
    }
    
}
