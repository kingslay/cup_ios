//
//  AddClockViewController.swift
//  Cup
//
//  Created by king on 16/9/3.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import SwiftDate
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .plain, target: self, action: #selector(complete))
        self.ks.autoAdjustKeyBoard()
    }
    func complete() {
        let model = ClockModel(hour:  datePicker.date.hour, minute:  datePicker.date.minute)
        if explanationTextField.text?.characters.count > 0 {
            model.explanation = explanationTextField.text!
        } else {
            model.explanation = explanationTextField.placeholder!
        }
        model.save()
        model.addUILocalNotification()
        if let block = addModel {
            block(model)
        }
        self.navigationController?.popViewController(animated: false)
    }

}
