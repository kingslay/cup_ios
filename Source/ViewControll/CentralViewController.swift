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
internal class CentralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BKCentralDelegate, BKAvailabilityObserver {
    
    // MARK: Properties
    private let indicatorView = IndicatorView()
    private let discoveriesTableView = UITableView()
    private var discoveries = [BKDiscovery]()
    private let discoveriesTableViewCellIdentifier = "Discoveries Table View Cell Identifier"
    private let central = BKCentral()
    
    // MARK: UIViewController Life Cycle
    
    internal override func viewDidLoad() {
        view.backgroundColor = UIColor.whiteColor()
//        navigationItem.title = "Central"
        discoveriesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: discoveriesTableViewCellIdentifier)
        discoveriesTableView.dataSource = self
        discoveriesTableView.delegate = self
        discoveriesTableView.tableFooterView = UIView()
        view.addSubview(discoveriesTableView)
        view.addSubview(indicatorView)
        applyConstraints()
        startCentral()
    }
    
    internal override func viewDidAppear(animated: Bool) {
        scan()
    }
    
    internal override func viewWillDisappear(animated: Bool) {
        central.interrupScan()
    }
    
    deinit {
        try! central.stop()
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
    
    private func startCentral() {
        do {
            central.delegate = self
            central.addAvailabilityObserver(self)
            let dataServiceUUID = NSUUID(UUIDString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            let dataServiceCharacteristicUUID = NSUUID(UUIDString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let configuration = BKConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch let error {
            print("Error while starting: \(error)")
        }
    }
    
    private func scan() {
        central.scanContinuouslyWithChangeHandler({ changes, discoveries in
            let indexPathsToRemove = changes.filter({ $0 == .Remove(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            self.discoveries = discoveries
            let indexPathsToInsert = changes.filter({ $0 == .Insert(discovery: nil) }).map({ NSIndexPath(forRow: self.discoveries.indexOf($0.discovery)!, inSection: 0) })
            if !indexPathsToRemove.isEmpty {
                self.discoveriesTableView.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            if !indexPathsToInsert.isEmpty {
                self.discoveriesTableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }, stateHandler: { newState in
            if newState == .Scanning {
                self.indicatorView.startAnimating()
                return
            } else if newState == .Stopped {
                self.discoveries.removeAll()
                self.discoveriesTableView.reloadData()
            }
            self.indicatorView.hidden = true
            self.indicatorView.stopAnimating()
        }, errorHandler: { error in
        })
    }
    
    // MARK: UITableViewDataSource
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(discoveriesTableViewCellIdentifier, forIndexPath: indexPath)
        let discovery = discoveries[indexPath.row]
        cell.textLabel?.text = discovery.localName != nil ? discovery.localName : discovery.remotePeripheral.name
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.userInteractionEnabled = false
        central.connect(remotePeripheral: discoveries[indexPath.row].remotePeripheral) { remotePeripheral, error in
            tableView.userInteractionEnabled = true
            guard error == nil else {
                print("Error connecting peripheral: \(error)")
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return
            }
            staticIdentifier = remotePeripheral.identifier.UUIDString
            UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.instance.instantiateInitialViewController()
        }
    }
    
    // MARK: BKAvailabilityObserver
    
    internal func availabilityObserver(availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        alertForAvailability(availability)
        if availability == .Available {
            scan()
        } else {
            central.interrupScan()
        }
    }
    internal func availabilityObserver(availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        alertForAvailability(.Unavailable(cause: unavailabilityCause))
    }
    private func alertForAvailability(availability: BKAvailability?){
        if let availability = availability {
            switch availability {
            case .Unavailable(cause: .PoweredOff):
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
                break
            case .Unavailable(cause: .Unsupported):
//                self.noticeOnlyText("抱歉你的设备不支持蓝牙。无法使用本应用")
                break
            default:
                break
            }
        }
    }
    
    // MARK: BKCentralDelegate
    
    internal func central(central: BKCentral, remotePeripheralDidDisconnect remotePeripheral: BKRemotePeripheral) {
        self.navigationController?.popToViewController(self, animated: true)
    }
}
