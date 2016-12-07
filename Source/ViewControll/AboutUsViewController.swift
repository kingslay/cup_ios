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
        self.tableView.register(R.nib.mineTableViewCell)
        self.tableView.rowHeight = 51
        let tableHeaderView = UIView(frame: CGRect(x: 0,y: 0,width: KS.SCREEN_WIDTH,height: 221))
        tableHeaderView.backgroundColor = UIColor.clear
        let image = UIImageView(image: R.image.lOGO())
        tableHeaderView.addSubview(image)
        self.tableView.tableHeaderView = tableHeaderView
        image.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(51)
            make.centerX.equalTo(tableHeaderView)
        }
        let lable = UILabel()
        lable.text = "杭州未蓝智能科技有限公司"
        lable.textColor = Colors.pink
        lable.numberOfLines = -1
        lable.textAlignment = .center
        lable.sizeToFit()
        self.view.addSubview(lable)
        lable.ks.centerX(self.view.ks.centerX)
        lable.ks.bottom(self.view.ks.bottom - 100)
    }
}
extension AboutUsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.mineTableViewCell)!
        cell.headerImageView.isHidden = true
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        if (indexPath as NSIndexPath).row == 0 {
            cell.iconImageView.image = R.image.icon_web()
            cell.titleLabel.text = "进入官网"
        }else if (indexPath as NSIndexPath).row == 1 {
            cell.iconImageView.image = R.image.icon_buy()
            cell.titleLabel.text = "购买"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            UIApplication.shared.openURL(URL(string: "http://www.8amcup.com")!)
        } else if (indexPath as NSIndexPath).row == 1 {
            UIApplication.shared.openURL(URL(string: "https://shop152288103.taobao.com")!)
        }
    }
}
