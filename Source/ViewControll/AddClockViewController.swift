//
//  AddClockViewController.swift
//  Cup
//
//  Created by king on 16/9/3.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit

class AddClockViewController: UIViewController {
    @IBOutlet weak var explanationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .Plain, target: self, action: #selector(complete))
        self.navigationItem.rightBarButtonItem?.tintColor = Colors.background
        
    }
    func complete() {
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
