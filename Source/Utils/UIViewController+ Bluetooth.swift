//
//  UIViewController+ Bluetooth.swift
//  Cup
//
//  Created by king on 15/11/17.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import CoreBluetooth

public protocol BluetoothDelegate : NSObjectProtocol{
  var serviceUUIDs: [CBUUID]? {get}
  func scanForPeripherals(central: CBCentralManager)
  func characteristicUUIDs(service: CBUUID) -> [CBUUID]?
  func didDiscoverPeripheral(peripheral: CBPeripheral)
  func didDiscoverCharacteristicsForService(characteristic: CBCharacteristic)
}
//extension BluetoothDelegate where Self: UIViewController, Self: CBPeripheralDelegate {
extension UIViewController: BluetoothDelegate,CBCentralManagerDelegate,CBPeripheralDelegate {
  public var serviceUUIDs: [CBUUID]? {
    get{
      return nil
    }
  }
  
  public func scanForPeripherals(central: CBCentralManager) {
    central.scanForPeripheralsWithServices(nil, options: nil)
  }
  
  public func characteristicUUIDs(service: CBUUID) -> [CBUUID]? {
    return nil
  }
  public func didDiscoverPeripheral(peripheral: CBPeripheral) {
    
  }
  public func didDiscoverCharacteristicsForService(characteristic: CBCharacteristic) {
    
  }
  
  public func centralManagerDidUpdateState(central: CBCentralManager) {
    if central.state == .PoweredOn {
      self.scanForPeripherals(central)
    }else if central.state == .PoweredOn {
      let alertController = UIAlertController(title: nil, message: "打开蓝牙来允许本应用连接到配件", preferredStyle: .Alert)
      self.presentViewController(alertController, animated: true, completion: nil)
      let prefsAction = UIAlertAction(title: "设置", style: .Default, handler: {
        (let action) -> Void in
        UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=Bluetooth")!)
      })
      let okAction = UIAlertAction(title: "好", style: UIAlertActionStyle.Default) {
        (_) -> Void in
      }
      alertController.addAction(prefsAction)
      alertController.addAction(okAction)
    }else if central.state == .Unsupported {
      self.noticeOnlyText("抱歉你的设备不支持蓝牙。无法使用本应用")
    }
    
  }
  public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    self.didDiscoverPeripheral(peripheral)
  }
  public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    peripheral.delegate = self
    peripheral.discoverServices(serviceUUIDs)
  }
  public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    print(error)
  }
  
  public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
  {
    if let services = peripheral.services {
      for service in services {
        service.peripheral.discoverCharacteristics(characteristicUUIDs(service.UUID), forService: service)
      }
    }
  }
  public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        self.didDiscoverCharacteristicsForService(characteristic)
      }
    }
  }
}
extension UIViewController {
    public func ksAutoAdjustKeyBoard() {
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillShowNotification).takeUntil(self.rx_deallocated).subscribeNext{ [weak self] notification in
            if let stongSelf = self, inputView = stongSelf.ksFindFirstResponder() {
                let userInfo: NSDictionary = notification.userInfo!
                let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
                let window = UIApplication.sharedApplication().keyWindow
                let relatedView = stongSelf.ks_relatedViewFor(inputView)
                if let convertRect = relatedView.superview?.convertRect(relatedView.frame, toView: window) {
                    let diff = CGRectGetMaxY(convertRect) - CGRectGetMinY(keyboardRect) + 10
                    if diff > 0 {
                        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0
                        UIView.animateWithDuration(duration, animations: {
                            var bounds = stongSelf.view.bounds
                            bounds.origin.y += diff
                            stongSelf.view.bounds = bounds
                        })
                    }
                }
            }
        }
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillHideNotification).takeUntil(self.rx_deallocated).subscribeNext{ [weak self] notification in
            if let stongSelf = self {
                let userInfo: NSDictionary = notification.userInfo!
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0
                UIView.animateWithDuration(duration, animations: {
                    let frame = stongSelf.view.frame
                    stongSelf.view.bounds = frame
                })
            }
            
        }
    }
    public func ks_relatedViewFor(inputView: UIView) -> UIView {
        return inputView
    }
    
    public func ksFindFirstResponder() -> UIView? {
        return recursionTraverseFindFirstResponderIn(self.view)
    }
    private func recursionTraverseFindFirstResponderIn(view: UIView) -> UIView? {
        for subView in view.subviews {
            if subView.isFirstResponder() {
                return subView
            }
            if let subView = recursionTraverseFindFirstResponderIn(subView) {
                return subView
            }
        }
        return nil
    }

}

