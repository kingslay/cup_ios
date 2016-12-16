//
//  AddWaterViewController.swift
//  Cup
//
//  Created by king on 2016/12/16.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

class AddWaterViewController: UITableViewController {
    var model = WaterModel()
    var addModel: ((WaterModel)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(complete))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = "添加喝水量"
        self.tableView.register(R.nib.mineTableViewCell)
        self.tableView.rowHeight = 51
        self.tableView.backgroundColor = Colors.background
        self.tableView.tableFooterView = UIView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! MineTableViewCell
        cell.valueTextField.becomeFirstResponder()
    }
    func complete() {
        model.save()
        if let block = addModel {
            block(model)
        }
        self.navigationController!.popViewController(animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.mineTableViewCell, for: indexPath)!
//        cell.iconImageView.isHidden = true
        cell.valueTextField.isHidden = false
        cell.headerImageView.isHidden = true
        cell.valueTextField.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.titleLabel?.text = "日期"
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.maximumDate = Date()
            cell.valueTextField.inputView = datePicker
            datePicker.date = Date()
            datePicker.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self,unowned cell,unowned datePicker] in
                let date = datePicker.date
                self.model.date = date.ks.string(fromFormat:"yyyy-MM-dd")
                cell.valueTextField.text = date.ks.string(fromFormat:"yyyy年MM月dd日")
            }).addDisposableTo(ks.disposableBag)
            datePicker.sendActions(for: .valueChanged)
        case 1:
            cell.titleLabel?.text = "时间"
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .time
            cell.valueTextField.inputView = datePicker
            datePicker.date = Date()
            datePicker.rx.controlEvent(.valueChanged).subscribe(onNext: { [unowned self,unowned cell,unowned datePicker] in
                let date = datePicker.date
                self.model.hour = date.ks.hour
                self.model.minute = date.ks.minute
                self.model.date = date.ks.string(fromFormat:"yyyy-MM-dd")
                cell.valueTextField.text = date.ks.string(fromFormat:"hh:mm")
            }).addDisposableTo(ks.disposableBag)
            datePicker.sendActions(for: .valueChanged)
        case 2:
            cell.titleLabel?.text = "喝水量(ml)"
            cell.valueTextField.keyboardType = .numberPad
            cell.valueTextField.rx.controlEvent(.allEvents).subscribe(onNext: { [unowned self,unowned cell] in
                if let text = cell.valueTextField.text,let amount = Int(text) {
                    self.model.amount = amount
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                } else {
                    self.model.amount = 0
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                }
            }).addDisposableTo(ks.disposableBag)
        default:
            break
        }
        return cell
    }
}
