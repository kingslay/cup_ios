//
//  KSDatePickerView.swift
//  Cup
//
//  Created by king on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
public class KSDatePickerView: UIView {
    public var datePicker = UIDatePicker()
    public var callBackBlock: (NSDate -> Void)?

    init() {
        let frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 260)
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        let toolBar = UIView(frame: CGRectMake(0, 0, frame.width, 44))
        let okButton = UIButton.init(frame: CGRectMake(0, 0, 44, 44))
        okButton.setTitle("完成".localized, forState: .Normal)
        okButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        okButton.ks_right = toolBar.ks_right - 10
        okButton.addTarget(self, action: "doneButtonClicked:", forControlEvents: .TouchUpInside)
        toolBar.addSubview(okButton)
        self.addSubview(toolBar)
        
        self.datePicker.frame = CGRectMake(0.0, toolBar.frame.height, toolBar.frame.width, self.frame.height - toolBar.frame.height)
        self.addSubview(datePicker)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func doneButtonClicked(sender: UIBarButtonItem) {
        if callBackBlock != nil {
            callBackBlock!(self.datePicker.date)
        }
    }

}
