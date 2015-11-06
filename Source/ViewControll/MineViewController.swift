//
//  MineViewController.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class MineViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.tableView.registerNib(R.nib.mineTableViewCell)
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.mineTableViewCell.reuseIdentifier, forIndexPath: indexPath)
        if indexPath.row == 0 {
            if let str = staticAccount?.headImageURL,url = NSURL(string: str) {
                cell?.headerImageView.af_setImageWithURL(url, placeholderImage: R.image.mine_photo)
            }else{
                cell?.headerImageView.image = R.image.mine_photo
            }
            cell?.headerImageView
            cell?.nickNameLabel.text = staticAccount?.nickname
        }
        return cell!
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.ks_pushViewController(AccountViewController())
        }
    }

}
