//
//  KSPickerView.swift
//  PolyGe
//
//  Created by king on 15/5/3.
//  Copyright (c) 2015年 king. All rights reserved.
//

import UIKit

public class KSPickerView: UIView ,UIPickerViewDataSource, UIPickerViewDelegate {
    private var pickerView = UIPickerView()
    public var callBackBlock: ([Int] -> Void)?
    public var pickerData  = [[]]{
        didSet(newValue){
            pickerView.selectRow(0, inComponent: 0, animated: false)
            pickerView.reloadAllComponents()
        }
    }
    override init(frame: CGRect) {
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

        self.pickerView.frame = CGRectMake(0.0, toolBar.frame.height, toolBar.frame.width, self.frame.height - toolBar.frame.height)
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.showsSelectionIndicator = true;
        self.pickerView.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.pickerView)
    }
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func doneButtonClicked(sender: UIBarButtonItem) {
        if callBackBlock != nil {
            var result: [Int] = []
            (0..<pickerView.numberOfComponents).forEach{ result.append(pickerView.selectedRowInComponent($0)) }
            callBackBlock!(result)
        }
    }
    // MARK - Picker delegate
    public func pickerView(_pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    public func numberOfComponentsInPickerView(_pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    
    public func pickerView(_pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row] as? String
    }

}
