//
//  FirstViewController.swift
//  Cup
//
//  Created by king on 15/10/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import RxSwift
import CoreBluetooth
//import RxBluetooth

class CupViewController: UITableViewController {
  var headerView = R.nib.cupHeaderView.firstView(nil, options: nil)
  var temperatureArray : [TemperatureModel] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = Colors.background
    let rightButton = UIBarButtonItem.init(barButtonSystemItem: .Add, target: self, action: "addTemperature")
    //        self.navigationItem.rightBarButtonItem = rightButton
    self.tableView.registerNib(R.nib.temperatureTableViewCell)
    self.setTableHeaderView()
    self.tableView.estimatedRowHeight = 45
    self.setUpCentral()
  }
  var central: CBCentralManager!
  var peripheral: CBPeripheral!
  let bag = DisposeBag()
  func setUpCentral() {
    central = CBCentralManager(delegate: nil, queue: nil)
    central.rx_didUpdateState.subscribeNext{
      if $0.state == .PoweredOn {
        $0.scanForPeripheralsWithServices(nil, options: nil)
      }else if $0.state == .PoweredOn {
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
      }else if $0.state == .Unsupported {
        self.noticeOnlyText("抱歉你的设备不支持蓝牙。无法使用本应用")
      }
    }.addDisposableTo(bag)
    central.rx_didDiscoverPeripheral.subscribeNext { [unowned self] in
      let name = $0.1.name
      if name?.length > 0 {
        self.peripheral = $0.1
        $0.0.connectPeripheral(self.peripheral, options: nil)
      }
    }.addDisposableTo(bag)
    central.rx_didConnectPeripheral.subscribeNext{
      $0.discoverServices(nil)
      $0.rx_didDiscoverServices.subscribeNext {
        if let services = $0.0.services {
          for var service in services {
            service.peripheral.discoverCharacteristics(nil, forService: service)
          }
        }
      }
      
    }.addDisposableTo(bag)
    central.rx_didFailToConnectPeripheral.subscribeNext{
      $0.0.name
    }.addDisposableTo(bag)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.temperatureArray = TemperatureModel.getTemperatures()
    self.tableView.reloadData()
  }
  
  func setTableHeaderView() {
    headerView?.ks_height = 204
    self.tableView.tableHeaderView = headerView
  }
}
extension CupViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return temperatureArray.count
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let model = temperatureArray[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(R.nib.temperatureTableViewCell.reuseIdentifier, forIndexPath: indexPath)!
    cell.backgroundColor = Colors.background
    cell.selectionStyle = .None
    cell.explanationLabel.text = model.explanation
    cell.temperatureLabel.text = "\(model.temperature)度"
    cell.openSwitch.on = model.open
    cell.openSwitch.rx_controlEvents(.TouchUpInside).subscribeNext{ [unowned cell,unowned self] in
      let on = cell.openSwitch.on
      if on {
        self.temperatureArray.forEach{
          $0.open = false
        }
        model.open = on
        self.headerView?.meTemperaturelabel.text = "\(model.temperature)"
        tableView.reloadData()
      } else {
        model.open = on
      }
    }
    return cell
  }
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    let label = UILabel()
    label.font = UIFont.systemFontOfSize(17)
    label.text = "恒温设定"
    label.sizeToFit()
    headerView.addSubview(label)
    label.snp_makeConstraints { (make) -> Void in
      make.left.equalTo(17)
      make.centerY.equalTo(headerView)
    }
    let button = UIButton()
    button.setImage(R.image.plus, forState: .Normal)
    headerView.addSubview(button)
    button.snp_makeConstraints { (make) -> Void in
      make.width.height.equalTo(27)
      make.right.equalTo(-12)
      make.centerY.equalTo(0)
    }
    button.rx_tap.subscribeNext { [unowned self] in
      let vc = R.nib.temperatureViewController.firstView(nil, options: nil)!
      self.presentViewController(vc, animated: true, completion: nil)
    }
    return headerView
  }
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "恒温设定"
  }
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
      temperatureArray.removeAtIndex(indexPath.row)
      TemperatureModel.setObjectArray(temperatureArray, forKey: "temperatureArray")
    }
  }
}

