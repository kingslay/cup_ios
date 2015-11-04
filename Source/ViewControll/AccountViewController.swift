//
//  AccountViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class AccountViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(R.nib.accountTableViewCell)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.accountTableViewCell.reuseIdentifier, forIndexPath: indexPath)!
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            cell.titleLabel.text = "我的头像"
            break
        case (0,1):
            cell.titleLabel.text = "我的昵称"
            break
        case (1,0):
            cell.titleLabel.text = "生日"
            break
        case (1,1):
            cell.titleLabel.text = "身高"
            break
        case (1,2):
            cell.titleLabel.text = "城市"
            break
        default:
            break
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AccountTableViewCell
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            
            break
        case (0,1):
            
            break
        case (1,0):
            let pickerView = KSPickerView.init(frame: CGRectMake(0, SCREEN_HEIGHT-250,SCREEN_WIDTH, 250))
            pickerView.pickerData = [Array(1900...2015).map{"\($0)年"},Array(1...12).map{"\($0)月"},Array(1...31).map{"\($0)日"}]
            pickerView.callBackBlock = {
                cell.valueLabel.text = "\($0)年月日"
            }
            break
        case (1,1):

            break
        case (1,2):
            
            break
        default:
            break
        }

    }

}
