//
//  FirstViewController.swift
//  Cup
//
//  Created by king on 15/10/11.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import Async
import RxSwift
import CoreBluetooth
import KSSwiftExtension
class CupViewController: UITableViewController {
    let disposeBag = DisposeBag()
    var headerView = R.nib.cupHeaderView.firstView(owner: nil, options: nil)
    var temperatureArray : [TemperatureModel] = []
    var central: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristic: Variable<CBCharacteristic?> = Variable(nil)
    var selectedIndex: Int?
    var timer: Timer?
    var durationTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors.background
        self.tableView.register(R.nib.temperatureTableViewCell)
        self.setTableHeaderView()
        self.tableView.estimatedRowHeight = 45
        self.setUpCentral()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(askTemperature), for: UIControlEvents.valueChanged)
        //修改下拉刷新标题
        refreshControl?.attributedTitle = NSAttributedString(string: "释放刷新")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.temperatureArray = TemperatureModel.getTemperatures()
        if let _ = self.selectedIndex {
            var i = 0
            var hasSet = false
            self.temperatureArray.forEach {
                if $0.open {
                    if !hasSet {
                        self.selectedIndex = i
                        hasSet = true
                    } else {
                        $0.open = false
                    }
                }
                i+=1
            }
            self.sendTemperature()
        } else {
            self.temperatureArray.forEach {
                if $0.open {
                    $0.open = false
                    $0.save()
                }
            }
        }
        self.tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        endRefreshing()
    }
    
    func setTableHeaderView() {
        headerView?.ks.height(204)
        self.tableView.tableHeaderView = headerView
        let view = UIView(frame: CGRect(x: 0,y: 204,width: self.view.ks.width,height: self.view.ks.height))
        view.alpha = 0.5
        view.backgroundColor = UIColor.black
        self.view.addSubview(view)
        let tapGestureRecognizer = UITapGestureRecognizer()
        headerView?.meTemperaturelabel.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
            if view.superview != nil {
                view.removeFromSuperview()
            }else{
                self.view.addSubview(view)
                self.temperatureArray.forEach{
                    $0.open = false
                }
                self.tableView.reloadData()
            }
            }).addDisposableTo(disposeBag)
        self.characteristic.asObservable().subscribe(onNext: {
            if $0 != nil {
                view.removeFromSuperview()
            }
            }).addDisposableTo(disposeBag)
    }
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        if let peripheral = self.peripheral {
            self.central.cancelPeripheralConnection(peripheral)
        }
    }
}
extension CupViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temperatureArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = temperatureArray[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.temperatureTableViewCell, for: indexPath)!
        cell.backgroundColor = Colors.background
        cell.selectionStyle = .none
        cell.explanationLabel.text = model.explanation
        cell.temperatureLabel.text = "\(model.temperature)度"
        cell.openSwitch.isOn = model.open
        cell.openSwitch.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned cell,unowned self] in
            let on = cell.openSwitch.isOn
            if on {
                if self.characteristic.value == nil {
                    self.alterCentralViewController()
                    Async.main(after: 0.35) {
                        cell.openSwitch.isOn = false
                    }
                } else {
                    self.temperatureArray.forEach{
                        $0.open = false
                    }
                    model.open = on
                    tableView.reloadData()
                    self.selectedIndex = indexPath.row
                    self.ks.pleaseWait("正在下达指令 请稍后")
                    self.sendTemperature()
                }
            } else {
                model.open = on
                self.selectedIndex = nil
            }
            }).addDisposableTo(cell.disposeBag)
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "恒温设定"
        label.sizeToFit()
        headerView.addSubview(label)
        label.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(17)
            make.centerY.equalTo(headerView)
        }
        let button = UIButton()
        button.setImage(UIImage(named: R.image.plus.name), for: .normal)
        headerView.addSubview(button)
        button.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(27)
            make.right.equalTo(-12)
            make.centerY.equalTo(headerView)
        }
        if self.temperatureArray.count >= 5 {
            button.removeFromSuperview()
        }
        button.rx.tap.subscribe(onNext: { [unowned self] in
            let vc = R.nib.temperatureViewController.firstView(owner: nil, options: nil)!
            self.navigationController?.present(vc, animated: true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "恒温设定"
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let model = self.temperatureArray[(indexPath as NSIndexPath).row]
        let editAction = UITableViewRowAction(style: .default, title: "编辑") {
           (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            let vc = R.nib.temperatureViewController.firstView(owner: nil, options: nil)!
            vc.model = model
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
        let deleteAction = UITableViewRowAction(style: .default, title: "删除") {[unowned self]
            (action: UITableViewRowAction!, indexPath: IndexPath!) -> Void in
            model.delete()
            self.temperatureArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
        editAction.backgroundColor = Colors.red
        deleteAction.backgroundColor = Colors.red
        return [deleteAction,editAction]
    }
}
extension CupViewController {
    func setUpCentral() {
        self.central = CBCentralManager(delegate: self, queue: nil)
    }
    override func scanForPeripherals(_ central: CBCentralManager) {
        if let staticIdentifier = staticIdentifier, let identifier = UUID(uuidString: staticIdentifier) {
            self.durationTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(durationTimerElapsed), userInfo: nil, repeats: false)
            let peripherals = self.central.retrievePeripherals(withIdentifiers: [identifier])
            if peripherals.count > 0 {
                didDiscoverPeripheral(peripherals[0])
            }
        }else{
            alterCentralViewController()
        }
    }
    @objc fileprivate func durationTimerElapsed() {
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        if self.characteristic.value == nil {
            let alertController = UIAlertController(title: "找不到之前设定的蓝牙的设备，是否要重新扫描，设定蓝牙设备", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "是", style: UIAlertActionStyle.default){
                (action: UIAlertAction!) -> Void in
                self.navigationController?.pushViewController(CentralViewController(), animated: true)
            }
            let cancelAction = UIAlertAction(title: "否", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    override func didDiscoverPeripheral(_ peripheral: CBPeripheral) {
        if peripheral.identifier.uuidString == staticIdentifier {
            self.peripheral = peripheral
            self.central.connect(peripheral, options: nil)
            self.central.stopScan()
        }
    }
    override func didDiscoverCharacteristicsForService(_ characteristic: CBCharacteristic) {
        if characteristic.properties.contains([.notify]) {
            self.peripheral?.setNotifyValue(true, for: characteristic)
        }
        if characteristic.properties.contains([.write]) {
            self.characteristic.value = characteristic
            self.timer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(askTemperature), userInfo: nil, repeats: true)
            self.timer?.fire()
            //连接通过之后，发送一下。让杯子叫一下
            let data = NSMutableData()
            data.ks.appendUInt8(0x3a)
            data.ks.appendUInt8(0x11)
            data.ks.appendUInt16(0x00)
            data.ks.appendUInt16(0x00)
            data.ks.appendUInt8(0x11)
            data.ks.appendUInt8(0x0a)
            self.peripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
        }
    }
    
    override var serviceUUIDs: [CBUUID]? {
        get{
            return [CBUUID(string: "FFE0"),CBUUID(string: "FFE5")]
        }
    }
    override func characteristicUUIDs(_ service: CBUUID) -> [CBUUID]? {
        //监听的通道
        if service.uuidString == "FFE0" {
            return [CBUUID(string: "FFE4")]
        }else  if service.uuidString == "FFE5" {
            return [CBUUID(string: "FFE9")]
        }
        return nil
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard let data = characteristic.value else {
            return
        }
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        guard  bytes[0] == 0x3a else {
            return
        }
        ///设置温度返回
        if bytes[1] == 0x88 {
            Async.main(after: 1){
                self.ks.clearAllNotice()
            }
            guard let selectedIndex = self.selectedIndex else {
                return
            }
            let temperature = self.temperatureArray[selectedIndex].temperature
            self.headerView?.meTemperaturelabel.text = "\(temperature)"
            self.headerView?.meExplanation.text = self.temperatureArray[selectedIndex].explanation
            if let text = self.headerView?.cupTemperaturelabel.text,let cupTemperature = Int(text) {
                if abs(cupTemperature - temperature) <= 1 {
                    self.headerView?.cupTemperatureImageView.image = R.image.已恒温()
                    let alertController = UIAlertController(title: "亲! 水温已到达最适宜度数!", message: "请及时享用哦。", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                }else{
                    self.headerView?.cupTemperatureImageView.image = R.image.恒温中()
                }
                
            }
        }else if bytes[1] == 0x44 {
            self.ks.noticeError("校验码错误")
        }else if bytes[1] == 0x01 || bytes[1] == 0x02 {
            //0x01是达到设置的温度 蓝牙自动返回
            //查询温度返回
            if bytes[1] == 0x02  {
                endRefreshing()
            }
            var cupTemperature: UInt16 = 0
            (data as NSData).getBytes(&cupTemperature, range: NSMakeRange(2,2))
            cupTemperature =  (cupTemperature / 10)
            self.headerView?.cupTemperaturelabel.text = "\(cupTemperature)"
            guard let selectedIndex = self.selectedIndex else {
                return
            }
            let temperature = self.temperatureArray[selectedIndex].temperature
            if abs(Int(cupTemperature) - temperature) <= 1  {
                self.headerView?.cupTemperatureImageView.image = R.image.已恒温()
                let alertController = UIAlertController(title: "亲! 水温已到达最适宜度数!", message: "请及时享用哦。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        self.timer?.invalidate()
        self.timer = nil
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        if let _ = error {
            self.central.connect(peripheral, options: nil)
        }
    }
    func alterCentralViewController() {
        let alertController = UIAlertController(title: "您还没有关联水杯设备,是否现在进行关联", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "是", style: UIAlertActionStyle.default){
            (action: UIAlertAction!) -> Void in
            self.navigationController?.pushViewController(CentralViewController(), animated: true)
        }
        let cancelAction = UIAlertAction(title: "否", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    func sendTemperature() {
        if let characteristic = self.characteristic.value, let selectedIndex = self.selectedIndex {
            let data = NSMutableData()
            data.ks.appendUInt8(0x3a)
            data.ks.appendUInt8(0x01)
            var val = UInt16(self.temperatureArray[selectedIndex].temperature * 10)
            data.append(&val, length: MemoryLayout.size(ofValue: val))
            data.ks.appendUInt16(0x00)
            let bytes = data.bytes.bindMemory(to: UInt8.self, capacity: data.length)
            data.ks.appendUInt8(bytes[1] + bytes[2] + bytes[3] + bytes[4] + bytes[5])
            data.ks.appendUInt8(0x0a)
            self.peripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
        }
    }
    func askTemperature() {
        if let characteristic = self.characteristic.value {
            let data = NSMutableData()
            data.ks.appendUInt8(0x3a)
            data.ks.appendUInt8(0x02)
            data.ks.appendUInt16(0x00)
            data.ks.appendUInt16(0x00)
            data.ks.appendUInt8(0x02)
            data.ks.appendUInt8(0x0a)
            self.peripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
        }
        refreshControl?.attributedTitle = NSAttributedString(string: "刷新中")
    }
}
extension UITableViewController {
    func endRefreshing() {
        refreshControl?.endRefreshing()
        refreshControl?.attributedTitle = NSAttributedString(string: "释放刷新")
    }
}
