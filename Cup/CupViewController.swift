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
  let disposeBag = DisposeBag()
  var headerView = R.nib.cupHeaderView.firstView(nil, options: nil)
  var temperatureArray : [TemperatureModel] = []
  var central: CBCentralManager!
  var peripheral: CBPeripheral!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.backgroundColor = Colors.background
    let rightButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addTemperature")
    //        self.navigationItem.rightBarButtonItem = rightButton
    self.tableView.registerNib(R.nib.temperatureTableViewCell)
    self.setTableHeaderView()
    self.tableView.estimatedRowHeight = 45
    self.setUpCentral()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.temperatureArray = TemperatureModel.getTemperatures()
    self.tableView.reloadData()
  }
  
  func setTableHeaderView() {
    headerView?.ks_height = 204
    self.tableView.tableHeaderView = headerView
    let view = UIView(frame: CGRectMake(0,204,self.view.ks_width,self.view.ks_height))
    view.alpha = 0.5
    view.backgroundColor = UIColor.blackColor()
    let tapGestureRecognizer = UITapGestureRecognizer()
    headerView?.meTemperaturelabel.addGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer.rx_event.subscribeNext{ [unowned self] _ in
        if view.superview != nil {
            view.removeFromSuperview()
        }else{
            self.view.addSubview(view)
            self.temperatureArray.forEach{
                $0.open = false
            }
            self.tableView.reloadData()
        }
    }.addDisposableTo(disposeBag)
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
    if self.temperatureArray.count >= 4 {
//        button.enabled = false
        button.removeFromSuperview()
    }
    button.rx_tap.subscribeNext { [unowned self] in
      let vc = R.nib.temperatureViewController.firstView(nil, options: nil)!
        self.navigationController?.presentViewController(vc, animated: true, completion: nil)
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
      temperatureArray.removeAtIndex(indexPath.row)
        self.tableView.reloadData()
//      self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
      TemperatureModel.setObjectArray(temperatureArray, forKey: "temperatureArray")
    }
  }
}
extension CupViewController {
  func setUpCentral() {
    central = CBCentralManager(delegate: self, queue: nil)
  }
  override func centralManager(central: CBCentralManager, peripheral: CBPeripheral) {
    if peripheral.identifier.UUIDString == "80208298-6E62-076C-A59B-C0E0A1C9949C" {
      self.peripheral = peripheral
      central.connectPeripheral(self.peripheral, options: nil)
    }
  }
}

