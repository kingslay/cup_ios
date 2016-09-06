//
//  WaterHistoryViewController.swift
//  Cup
//
//  Created by king on 16/8/16.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

class WaterHistoryViewController: ShareViewController {
    let segmented = UISegmentedControl(items: ["日","周","月"])
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.white
        segmented.frame = CGRect(x: 10, y: 10, width: self.view.ks.width-20, height: 20)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(valueChanged), forControlEvents: .ValueChanged)
        self.view.addSubview(segmented)
        self.view.addSubview(tableView)
        tableView.registerNib(R.nib.waterHistoryTableViewCell)
        self.tableView.rowHeight = 51
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(segmented.snp_bottom).offset(10)
            make.left.equalTo(0)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.tableView.tableHeaderView = self.chartView
        self.tableView.tableFooterView = UIView()
    }
    func valueChanged(seg: UISegmentedControl) {

    }
}
extension WaterHistoryViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.waterHistoryTableViewCell)!
        return cell
    }
    
}
