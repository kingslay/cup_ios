//
//  KSPickerView.swift
//  PolyGe
//
//  Created by king on 15/5/3.
//  Copyright (c) 2015年 king. All rights reserved.
//

import UIKit

open class KSPickerView: UIPickerView ,UIPickerViewDataSource, UIPickerViewDelegate {
    open var callBackBlock: (([Int]) -> Void)?
    open var pickerData  = [[]]{
        didSet(newValue){
            self.dataSource = self
            self.delegate = self
            self.selectRow(0, inComponent: 0, animated: false)
            self.reloadAllComponents()
        }
    }
    // MARK - Picker delegate
    open func pickerView(_ _pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    open func numberOfComponents(in _pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    
    open func pickerView(_ _pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row] as? String
    }
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if callBackBlock != nil {
            var result: [Int] = []
            (0..<pickerView.numberOfComponents).forEach{
                result.append(pickerView.selectedRow(inComponent: $0))
            }
            callBackBlock!(result)
        }
    }

}
