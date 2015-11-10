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
    var temperatureArray: [TemperatureModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
         let rightButton = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addTemperature")
        self.navigationItem.rightBarButtonItem = rightButton
        self.setTableHeaderView()
        self.tableView.registerNib(R.nib.temperatureTableViewCell)
        if let array = TemperatureModel.objectArrayForKey("temperatureArray") {
            temperatureArray = array as! [TemperatureModel]
        }
        self.tableView.estimatedRowHeight = 50
    }
    func addTemperature() {
        
        TemperatureModel.setObjectArray(self.temperatureArray,forKey:"temperatureArray")
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
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.temperatureTableViewCell.reuseIdentifier, forIndexPath: indexPath)
        cell?.explanationLabel.text = mode.explanation
        cell?.temperatureLabel.text = "\(mode.temperature)度"
        cell?.openSwitch.on = mode.open
        cell?.openSwitch.rx_value.subscribeNext{
            if $0 {
                self.temperatureArray.forEach{
                    $0.open = false
                }
            }
            mode.open = $0
            tableView.reloadData()
        }
        return cell!
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "恒温设定"
    }
}

