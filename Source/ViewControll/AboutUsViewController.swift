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
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let tableHeaderView = UIView(frame: CGRectMake(0,0,KS.SCREEN_WIDTH,221))
        tableHeaderView.backgroundColor = UIColor.whiteColor()
        let image = UIImageView(image: R.image.logo())
        tableHeaderView.addSubview(image)
        self.tableView.tableHeaderView = tableHeaderView
        image.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(51)
            make.width.equalTo(122)
            make.height.equalTo(135)
            make.centerX.equalTo(tableHeaderView)
        }
        let lable = UILabel()
        lable.text = "杭州未蓝智能科技有限公司"
//        \n杭州市萧山区兴五路237号\n0571－87703609"
        lable.numberOfLines = -1
        lable.textAlignment = .Center
        lable.sizeToFit()
        self.view.addSubview(lable)
        lable.ks.centerX(self.view.ks.centerX)
        lable.ks.bottom(self.view.ks.bottom - 100)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension AboutUsViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        cell.accessoryType = .DisclosureIndicator
        if indexPath.row == 0 {
            cell.textLabel?.text = "进入官网"
        }else if indexPath.row == 1 {
            cell.textLabel?.text = "购买"
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.8amcup.com")!)
        } else if indexPath.row == 1 {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://shop152288103.taobao.com")!)
        }
    }
}
