//
//  KSDatePickerView.swift
//  Cup
//
//  Created by king on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
public class KSDatePickerView: UIView {
    public var datePicker: UIDatePicker!
    public var callBackBlock: (NSDate -> Void)?

    init() {
        let frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 260)
        super.init(frame: frame)
        let toolBar = UIView(frame: CGRectMake(0, 0, frame.width, 44))
        datePicker.frame = CGRectMake(0.0, toolBar.frame.height, toolBar.frame.width, self.frame.height - toolBar.frame.height)
        let okButton = UIButton.init(frame: CGRectMake(0, 0, 44, 44))
        okButton.ks_right = toolBar.ks_right - 10
        toolBar.addSubview(okButton)
        self.addSubview(toolBar)
        self.addSubview(datePicker)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func doneButtonClicked(sender: UIBarButtonItem) {
        if callBackBlock != nil {
            callBackBlock!(self.datePicker.date)
        }
        self.hidden = true
    }

}
