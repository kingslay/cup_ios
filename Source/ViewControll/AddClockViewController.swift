//
//  AddClockViewController.swift
//  Cup
//
//  Created by king on 16/9/3.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import SwiftDate
class AddClockViewController: UIViewController {
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    var addModel: ((ClockModel)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .Plain, target: self, action: #selector(complete))
        self.ks.autoAdjustKeyBoard()
    }
    func complete() {
        let components = datePicker.date.components(inRegion: Region())
        let model = ClockModel(hour: components.hour, minute: components.minute)
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
        self.navigationController?.popViewControllerAnimated(false)
    }

}
