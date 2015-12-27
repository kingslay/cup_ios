//
//  BluetoothKit
//
//  Copyright (c) 2015 Rasmus Taulborg Hummelmose - https://github.com/rasmusth
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import BluetoothKit
import CoreBluetooth
import SnapKit
internal class CentralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
  
  // MARK: Properties
  private let indicatorView = IndicatorView()
  private let discoveriesTableView = UITableView()
  private let discoveriesTableViewCellIdentifier = "Discoveries Table View Cell Identifier"
  private var central: CBCentralManager!
  var discoveries: Set<CBPeripheral> = []
  // MARK: UIViewController Life Cycle
  
  internal override func viewDidLoad() {
    setupTableView()
    view.addSubview(indicatorView)
    applyConstraints()
    self.central = CBCentralManager(delegate: self, queue: nil)
  }
  
  func setupTableView() {
    discoveriesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: discoveriesTableViewCellIdentifier)
    discoveriesTableView.backgroundColor = Colors.background
    discoveriesTableView.dataSource = self
    discoveriesTableView.delegate = self
    view.addSubview(discoveriesTableView)
    let headerView = UIView(frame: CGRectMake(0,0,self.view.frame.width,245))
    let headerLabel = UILabel()
    headerLabel.text = "发现水杯"
    headerLabel.font = UIFont.systemFontOfSize(23)
    headerLabel.sizeToFit()
    headerView.addSubview(headerLabel)
    headerLabel.snp_makeConstraints { (make) -> Void in
      make.centerX.equalTo(0)
      make.bottom.equalTo(-20)
    }
    discoveriesTableView.tableHeaderView = headerView
    let footerView = UIView()
    let imageView = UIImageView(image: R.image.cup_adaptation)
    footerView.addSubview(imageView)
    imageView.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(30)
      make.centerX.equalTo(0)
    }
    let footerLabel = UILabel()
    footerLabel.text = "灯光闪烁表示已连接"
    footerLabel.font = UIFont.systemFontOfSize(16)
    footerLabel.sizeToFit()
    footerView.addSubview(footerLabel)
    footerLabel.snp_makeConstraints { (make) -> Void in
      make.top.equalTo(imageView.snp_bottom).offset(28)
      make.centerX.equalTo(0)
    }
    discoveriesTableView.tableFooterView = footerView
    headerView.hidden = true
    footerView.hidden = true
  }
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    indicatorView.startAnimating()
    NSNotificationCenter.defaultCenter().rx_notification(UIApplicationDidBecomeActiveNotification).subscribeNext{_ in
        self.indicatorView.startAnimating()
    }
  }
  deinit {
    central.stopScan()
  }
  
  // MARK: Functions
  
  private func applyConstraints() {
    discoveriesTableView.snp_makeConstraints { make in
      make.top.equalTo(snp_topLayoutGuideBottom)
      make.leading.trailing.equalTo(view)
      make.bottom.equalTo(view.snp_bottom)
    }
    indicatorView.snp_makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
  }
  
  override func didDiscoverPeripheral(peripheral: CBPeripheral) {
    if let name = peripheral.name where name == "8点am" || name.hasPrefix("TAv22u") {
      indicatorView.stopAnimating()
      discoveries.insert(peripheral)
      discoveriesTableView.tableHeaderView?.hidden = false
      discoveriesTableView.tableFooterView?.hidden = false
      discoveriesTableView.reloadData()
    }
  }
  
  // MARK: UITableViewDataSource
  
  internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return discoveries.count
  }
  
  internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(discoveriesTableViewCellIdentifier, forIndexPath: indexPath)
    let discovery = discoveries[discoveries.startIndex.advancedBy(indexPath.row)]
    cell.textLabel?.text = discovery.name
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.userInteractionEnabled = false
    let discovery = discoveries[discoveries.startIndex.advancedBy(indexPath.row)]
    central.connectPeripheral(discovery, options: nil)
  }
  override func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    staticIdentifier = peripheral.identifier.UUIDString
    central.cancelPeripheralConnection(peripheral)
    UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.instance.instantiateInitialViewController()
    
  }
  override func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
    if let error = error {
      self.noticeError("连接失败: \(error)")
      if let _ = discoveries.remove(peripheral) {
        discoveriesTableView.reloadData()
      }
    }
  }
}
