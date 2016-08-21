//
//  TemperatureViewController.swift
//  Cup
//
//  Created by king on 15/11/10.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
class TemperatureViewController: UIViewController {
    
    @IBOutlet weak var temperaturePickerView: UIPickerView!
    @IBOutlet weak var explanationTextField: UITextField!
    var pickerData = [Array(21...70).map{"\($0)度"}]
    var model: TemperatureModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ks.autoAdjustKeyBoard()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let model = model {
            explanationTextField.text = model.explanation
            temperaturePickerView.selectRow(model.temperature-21, inComponent: 0, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func saveAction(sender: AnyObject) {
        if var text = explanationTextField.text where text.length > 0 {
            if text.length > 10 {
                text = text[0..<10]
            }
            self.model?.delete()
            let model = self.model ?? TemperatureModel()
            model.explanation = text
            model.temperature = temperaturePickerView.selectedRowInComponent(0)+21
            model.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            self.noticeInfo("温度描述不能为空")
        }
    }
    @IBAction func textFieldDidEndOnExit(sender: UIResponder) {
        sender.resignFirstResponder()
    }
}
extension TemperatureViewController:UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK - Picker delegate
    func pickerView(_pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func numberOfComponentsInPickerView(_pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(_pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }

}
