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
import CoreBluetooth
import SnapKit
internal class CentralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
  
  // MARK: Properties
  fileprivate let indicatorView = IndicatorView()
  fileprivate let discoveriesTableView = UITableView()
  fileprivate let discoveriesTableViewCellIdentifier = "Discoveries Table View Cell Identifier"
  fileprivate var central: CBCentralManager!
  var discoveries: Set<CBPeripheral> = []
  // MARK: UIViewController Life Cycle
  
  internal override func viewDidLoad() {
    setupTableView()
    view.addSubview(indicatorView)
    applyConstraints()
  }
  
  func setupTableView() {
    discoveriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: discoveriesTableViewCellIdentifier)
    discoveriesTableView.backgroundColor = Colors.background
    discoveriesTableView.dataSource = self
    discoveriesTableView.delegate = self
    discoveriesTableView.rowHeight = 45
    view.addSubview(discoveriesTableView)
    let headerView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: 245))
    let headerLabel = UILabel()
    headerLabel.text = "发现智能水杯"
    headerLabel.font = UIFont.systemFont(ofSize: 24)
    headerLabel.textColor = Colors.red
    headerLabel.sizeToFit()
    headerView.addSubview(headerLabel)
    headerLabel.snp.makeConstraints { (make) -> Void in
      make.centerX.equalTo(0)
      make.bottom.equalTo(-20)
    }
    discoveriesTableView.tableHeaderView = headerView
    headerView.isHidden = true
    discoveriesTableView.tableFooterView = UIView()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    indicatorView.startAnimating()
    self.central = CBCentralManager(delegate: self, queue: nil)

    NotificationCenter.default.rx.notification(NSNotification.Name.UIApplicationDidBecomeActive).subscribe{_ in
        if self.discoveries.count == 0 {
            self.indicatorView.startAnimating()
        }
    }.addDisposableTo(self.ks.disposableBag)
  }
  deinit {
    central.stopScan()
  }
  
  // MARK: Functions
  
  fileprivate func applyConstraints() {
    discoveriesTableView.snp.makeConstraints { make in
      make.top.equalTo(self.topLayoutGuide.snp.bottom)
      make.leading.trailing.equalTo(view)
      make.bottom.equalTo(view.snp.bottom)
    }
    indicatorView.snp.makeConstraints { (make) -> Void in
      make.edges.equalTo(view)
    }
  }
  
  override func didDiscoverPeripheral(_ peripheral: CBPeripheral) {
    if let name = peripheral.name , name == "HMAI" || name.hasPrefix("TAv22u") {
      indicatorView.stopAnimating()
      discoveries.insert(peripheral)
      discoveriesTableView.tableHeaderView?.isHidden = false
      discoveriesTableView.tableFooterView?.isHidden = false
      discoveriesTableView.reloadData()
    }
  }
  
  // MARK: UITableViewDataSource
  
  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return discoveries.count
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: discoveriesTableViewCellIdentifier, for: indexPath)
    cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
    cell.textLabel?.textColor = Colors.pink
    let discovery = discoveries[discoveries.index(discoveries.startIndex, offsetBy: (indexPath as NSIndexPath).row)]
    cell.textLabel?.text = discovery.name
    return cell
  }
  
  // MARK: UITableViewDelegate
  
  internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.isUserInteractionEnabled = false
    let discovery = discoveries[discoveries.index(discoveries.startIndex, offsetBy: (indexPath as NSIndexPath).row)]
    central.connect(discovery, options: nil)
  }
  override func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    staticIdentifier = peripheral.identifier.uuidString
    central.cancelPeripheralConnection(peripheral)
    UIApplication.shared.keyWindow!.rootViewController = R.storyboard.main.instantiateInitialViewController()
    
  }
  override func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    if let error = error {
      self.ks.noticeError("连接失败: \(error)")
      if let _ = discoveries.remove(peripheral) {
        discoveriesTableView.reloadData()
      }
    }
  }
}
