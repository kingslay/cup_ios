//
//  FirstViewController.swift
//  Cup
//
//  Created by king on 15/10/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import RxSwift

class CupViewController: UITableViewController {
    var temperatureArray : [TemperatureModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors.tableBackground
        let rightButton = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addTemperature")
        self.navigationItem.rightBarButtonItem = rightButton
        self.tableView.registerNib(R.nib.temperatureTableViewCell)
        self.setTableHeaderView()
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 50
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.temperatureArray = TemperatureModel.getTemperatures()
        self.tableView.reloadData()
    }
    func addTemperature() {
        let vc = R.nib.temperatureViewController.firstView(nil, options: nil)!
        self.presentViewController(vc, animated: true, completion: nil)
    }
    func setTableHeaderView() {
        let headerView = R.nib.cupHeaderView.firstView(nil, options: nil)
        headerView?.ks_height = 300
        self.tableView.tableHeaderView = headerView
    }
}
extension CupViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temperatureArray.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mode = temperatureArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.temperatureTableViewCell.reuseIdentifier, forIndexPath: indexPath)!
        cell.backgroundColor = Colors.tableBackground
        cell.selectionStyle = .None
        cell.explanationLabel.text = mode.explanation
        cell.temperatureLabel.text = "\(mode.temperature)度"
        cell.openSwitch.hidden = true
        cell.openSwitch.on = mode.open
        cell.openSwitch.rx_controlEvents(.TouchUpInside).subscribeNext{ [unowned cell,unowned self] in
            let on = cell.openSwitch.on
            if on {
                self.temperatureArray.forEach{
                    $0.open = false
                }
                mode.open = on
                tableView.reloadData()
            } else {
                mode.open = on
            }
        }
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "恒温设定"
    }
}

