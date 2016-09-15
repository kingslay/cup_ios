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
    let tableHeaderView = R.nib.clockHeaderView.firstView(owner: nil)!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(R.nib.clockTableViewCell)
        self.tableView.backgroundColor = Colors.background
        self.tableView.rowHeight = 92
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .Plain, target: self, action: #selector(addClock))
        tableHeaderView.openSwitch.on = !close.value
        tableHeaderView.openSwitch.rx_value.subscribeNext { [unowned self] in
            if $0 {
                self.tableHeaderView.clockImageView.image = R.image.icon_clockRemind2()
            } else {
                self.tableHeaderView.clockImageView.image = R.image.icon_clockRemind1()
            }
            self.close.value = !$0
            ClockModel.close = self.close.value
            self.tableView.reloadData()
            }.addDisposableTo(self.ks.disposableBag)
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
         UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge,.Sound,.Alert], categories: nil))
        //        let fittingSize = tableHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableHeaderView.ks.height(218)
        self.tableView.tableHeaderView = tableHeaderView
    }
    func addClock() {
        let vc = R.nib.addClockViewController.firstView(owner: nil)!
        vc.addModel = { [unowned self] in
            self.clockArray.append($0)
            self.tableView.reloadData()
        }
        self.navigationController!.ks.pushViewController(vc)
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
            cell.timeTextField.textColor = Colors.black
            cell.explanationLabel.textColor = Colors.black
            cell.openSwitch.on = false
        } else {
            cell.timeTextField.textColor = Colors.pink
            cell.explanationLabel.textColor = Colors.pink
            cell.openSwitch.on = clockModel.open
        }
        return cell
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
        deleteAction.backgroundColor = Colors.red
        return [deleteAction]
    }
}
