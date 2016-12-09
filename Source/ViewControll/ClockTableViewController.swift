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
        self.tableView.register(R.nib.clockTableViewCell)
        self.tableView.backgroundColor = Colors.background
        self.tableView.rowHeight = 92
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .plain, target: self, action: #selector(addClock))
        tableHeaderView.openSwitch.isOn = !close.value
        tableHeaderView.openSwitch.rx.value.subscribe(onNext: { [unowned self] in
            if $0 {
                self.tableHeaderView.clockImageView.image = R.image.icon_clockRemind2()
            } else {
                self.tableHeaderView.clockImageView.image = R.image.icon_clockRemind1()
            }
            self.close.value = !$0
            ClockModel.close = self.close.value
            self.tableView.reloadData()
            }).addDisposableTo(self.ks.disposableBag)
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false
         UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge,.sound,.alert], categories: nil))
        //        let fittingSize = tableHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

    }
    override func viewWillAppear(_ animated: Bool) {
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.clockTableViewCell)!
        let clockModel = clockArray[(indexPath as NSIndexPath).row]
        cell.timeTextField.text = clockModel.description
        cell.explanationLabel.text = clockModel.explanation
        cell.openSwitch.rx.value.skip(1).subscribe(onNext: { (on) in
            clockModel.open = on
            clockModel.save()
            }).addDisposableTo(cell.ks.prepareForReusedisposableBag)
        if close.value {
            cell.timeTextField.textColor = Colors.black
            cell.explanationLabel.textColor = Colors.black
            cell.openSwitch.isOn = false
        } else {
            cell.timeTextField.textColor = Colors.pink
            cell.explanationLabel.textColor = Colors.pink
            cell.openSwitch.isOn = clockModel.open
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = self.clockArray[(indexPath as NSIndexPath).row]
        let deleteAction = UITableViewRowAction(style: .default, title: "删除") {[unowned self]
            (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            model.delete()
            self.clockArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        let editAction = UITableViewRowAction(style: .default, title: "编辑") {
            (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            let vc = R.nib.addClockViewController.firstView(owner: nil, options: nil)!
            vc.set(model:model)
            vc.addModel = { [unowned self] in
                self.clockArray.append($0)
                self.clockArray.remove(at: self.clockArray.index(of: model)!)
                self.tableView.reloadData()
                model.delete()
            }
            self.navigationController!.ks.pushViewController(vc)
        }

        editAction.backgroundColor = Colors.red
        deleteAction.backgroundColor = Colors.red
        return [deleteAction,editAction]
    }
}
