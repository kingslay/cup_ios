//
//  ClockTableViewController.swift
//  Cup
//
//  Created by king on 16/9/3.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import Rswift
import KSSwiftExtension
import RxSwift
class ClockTableViewController: UITableViewController {
    lazy var clockArray: [ClockModel] = ClockModel.getClocks()
    var close = Variable(ClockModel.close)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(R.nib.clockTableViewCell)
        let tableHeaderView = R.nib.clockHeaderView.firstView(owner: nil)!
        tableHeaderView.openSwitch.on = !close.value
        tableHeaderView.openSwitch.rx_value.subscribeNext { [unowned self] in
            if $0 {
                tableHeaderView.clockImageView.image = R.image.icon_clockRemind2()
            } else {
                tableHeaderView.clockImageView.image = R.image.icon_clockRemind1()
            }
            self.close.value = !$0
            ClockModel.close = self.close.value
            self.tableView.reloadData()
        }.addDisposableTo(self.ks.disposableBag)
        self.tableView.tableHeaderView = tableHeaderView
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .Plain, target: self, action: #selector(addClock))
    }
    func addClock() {
        let vc = R.nib.temperatureViewController.firstView(owner: nil, options: nil)!
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
    }
}
extension ClockTableViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockArray.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.clockTableViewCell)!
        let clockModel = clockArray[indexPath.row]
        cell.timeTextField.text = clockModel.description
        cell.explanationLabel.text = clockModel.explanation
        cell.openSwitch.rx_value.skip(1).subscribeNext { (on) in
            if on {
                clockModel.addUILocalNotification()
            } else {
                clockModel.removeUILocalNotification()
            }
            clockModel.open = on
            clockModel.save()
            }.addDisposableTo(cell.ks.prepareForReusedisposableBag)
        if close.value {
            cell.timeTextField.textColor = Swifty<UIColor>.colorFrom("#ffffff")
            cell.explanationLabel.textColor = Swifty<UIColor>.colorFrom("#ffffff")
            cell.openSwitch.on = false
        } else {
            cell.timeTextField.textColor = Colors.black
            cell.explanationLabel.textColor = Colors.black
            cell.openSwitch.on = clockModel.open
        }
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 92
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let model = self.clockArray[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .Default, title: "删除") {[unowned self]
            (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            model.delete()
            self.clockArray.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        }
        deleteAction.backgroundColor = Colors.black
        return [deleteAction]
    }
}
