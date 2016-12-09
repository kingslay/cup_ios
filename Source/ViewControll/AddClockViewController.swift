//
//  AddClockViewController.swift
//  Cup
//
//  Created by king on 16/9/3.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class AddClockViewController: UIViewController {
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    var addModel: ((ClockModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(complete))
        self.ks.autoAdjustKeyBoard()
    }
    func set(model: ClockModel) {
        explanationTextField.text = model.explanation
        datePicker.date = model.date
    }
    func complete() {
        let model = ClockModel(hour:  datePicker.date.ks.hour, minute: datePicker.date.ks.minute)
        if explanationTextField.text?.characters.count > 0 {
            model.explanation = explanationTextField.text!
        } else {
            model.explanation = explanationTextField.placeholder!
        }
        if let block = addModel {
            block(model)
        }
        model.save()
        self.navigationController!.popViewController(animated: false)
    }

}
