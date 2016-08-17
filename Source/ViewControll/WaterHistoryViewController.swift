//
//  WaterHistoryViewController.swift
//  Cup
//
//  Created by king on 16/8/16.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

class WaterHistoryViewController: ShareViewController,UITableViewDataSource,UITableViewDelegate {
    let segmented: UISegmentedControl = {
        let segmented = UISegmentedControl(items: ["日","周","月"])
        return segmented
    }()
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        segmented.frame = CGRect(x: 100, y: 0, width: 200, height: 20)
        self.view.addSubview(segmented)
        self.view.addSubview(tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(segmented.snp_bottom).offset(10)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.tableView.tableHeaderView = self.chartView
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
