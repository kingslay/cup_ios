//
//  AboutUsViewController.swift
//  Cup
//
//  Created by king on 15/11/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
class AboutUsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors.background
        self.tableView.registerNib(R.nib.mineTableViewCell)
        self.tableView.rowHeight = 51
        let tableHeaderView = UIView(frame: CGRectMake(0,0,KS.SCREEN_WIDTH,221))
        tableHeaderView.backgroundColor = UIColor.clearColor()
        let image = UIImageView(image: R.image.lOGO())
        tableHeaderView.addSubview(image)
        self.tableView.tableHeaderView = tableHeaderView
        image.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(51)
            make.centerX.equalTo(tableHeaderView)
        }
        let lable = UILabel()
        lable.text = "贺迈新能源科技（上海）有限公司"
        lable.textColor = Colors.pink
        lable.numberOfLines = -1
        lable.textAlignment = .Center
        lable.sizeToFit()
        self.view.addSubview(lable)
        lable.ks.centerX(self.view.ks.centerX)
        lable.ks.bottom(self.view.ks.bottom - 100)
    }
}
extension AboutUsViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.mineTableViewCell)!
        cell.headerImageView.hidden = true
        cell.selectionStyle = .None
        cell.accessoryType = .DisclosureIndicator
        if indexPath.row == 0 {
            cell.iconImageView.image = R.image.icon_web()
            cell.titleLabel.text = "进入官网"
        }else if indexPath.row == 1 {
            cell.iconImageView.image = R.image.icon_buy()
            cell.titleLabel.text = "购买"
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.8amcup.com")!)
        } else if indexPath.row == 1 {
            UIApplication.sharedApplication().openURL(NSURL(string: "www.heatmatetech.com")!)
        }
    }
}
