//
//  KSPickerView.swift
//  PolyGe
//
//  Created by king on 15/5/3.
//  Copyright (c) 2015年 king. All rights reserved.
//

import UIKit

public class KSPickerView: UIPickerView ,UIPickerViewDataSource, UIPickerViewDelegate {
    public var callBackBlock: ([Int] -> Void)?
    public var pickerData  = [[]]{
        didSet(newValue){
            self.dataSource = self
            self.delegate = self
            self.selectRow(0, inComponent: 0, animated: false)
            self.reloadAllComponents()
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
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if callBackBlock != nil {
            var result: [Int] = []
            (0..<pickerView.numberOfComponents).forEach{
                result.append(pickerView.selectedRowInComponent($0))
            }
            callBackBlock!(result)
        }
    }

}
