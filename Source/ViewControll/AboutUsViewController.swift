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
        let tableHeaderView = UIView(frame: CGRectMake(0,0,SCREEN_WIDTH,221))
        tableHeaderView.backgroundColor = UIColor.whiteColor()
        let image = UIImageView(image: R.image.logo)
        tableHeaderView.addSubview(image)
        self.tableView.tableHeaderView = tableHeaderView
        image.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(51)
            make.width.equalTo(122)
            make.height.equalTo(135)
            make.centerX.equalTo(tableHeaderView)
        }
        let lable = UILabel()
        lable.text = "杭州未蓝智能科技有限公司\n杭州市萧山区兴五路237号\n400-666-7566"
        lable.numberOfLines = -1
        lable.textAlignment = .Center
        lable.sizeToFit()
        self.view.addSubview(lable)
        lable.ks_centerX = self.view.ks_centerX
        lable.ks_bottom = self.view.ks_bottom - 100;
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
        cell.accessoryType = .DisclosureIndicator
        if indexPath.row == 0 {
            cell.textLabel?.text = "进入官网"
        }else{
            cell.textLabel?.text = "购买"
        }
        return cell
    }
}
