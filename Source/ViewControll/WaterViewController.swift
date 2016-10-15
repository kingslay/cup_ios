//
//  WaterViewController.swift
//  Cup
//
//  Created by king on 16/8/13.
//  Copyright © 2016年 king. All rights reserved.
//


import UIKit
import RxSwift
import CoreBluetooth
import KSSwiftExtension
import Charts
import CVCalendar

class WaterViewController: ShareViewController {
    var central: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristic: Variable<CBCharacteristic?> = Variable(nil)
    var selectedIndex: Int?
    var timer: Timer?
    var durationTimer: Timer?
    lazy var dateButton = UIButton()
    var calendarView: CalendarView!
    var waterCycleView: WaterCycleView!
    var currentDate = Foundation.Date() {
        didSet{
            self.dateButton.setTitle(currentDate.ks.string(fromFormat:"yyyy年MM月dd日"), for: UIControlState())
            self.setUpChartData(currentDate)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCentral()
        waterCycleView = WaterCycleView()
        waterCycleView.batteryRate = 100
        view.addSubview(waterCycleView)
        dateButton.setImage(R.image.icon_calendar(), for: .normal)
        dateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        dateButton.setTitleColor(Colors.pink, for: UIControlState())
        view.addSubview(dateButton)
        dateButton.snp_makeConstraints { (make) in
            make.top.equalTo(waterCycleView.ks.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        view.addSubview(chartView)
        chartView.snp_makeConstraints { (make) in
            make.top.equalTo(dateButton.snp_bottom)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-10)
        }
        let tapGesture = UITapGestureRecognizer()
        self.chartView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.subscribeNext{ [unowned self](_) in
            let vc = WaterHistoryViewController()
            vc.currentDate = self.currentDate
            self.navigationController?.ks.pushViewController(vc)
        }.addDisposableTo(self.ks.disposableBag)
        calendarView = CalendarView(frame: view.bounds)
        view.addSubview(calendarView)
        calendarView.ks.top(view.ks.bottom)
        dateButton.rx.tap.subscribeNext { [unowned self]_ in
            UIView.animate(withDuration: 0.35, animations: {
                self.calendarView.ks.bottom(self.view.ks.bottom)
            })
            }.addDisposableTo(ks.disposableBag)
        calendarView.update = { [unowned self] date in
            self.calendarView.ks.top(self.view.ks.bottom)
            self.currentDate = date.convertedDate()!
        }
        currentDate = Foundation.Date()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         waterCycleView.waterplan = CGFloat(staticAccount?.waterplan?.intValue ?? staticAccount!.calculateProposalWater())
    }
    func setUpChartData(_ date: Foundation.Date) {
        WaterModel.save(Foundation.Date(), amount: 80)
        var xVals = [String?]()
        var yVals = [BarChartDataEntry]()
        var water = 0
        if let models = WaterModel.fetch(date) {
            for (index,model) in models.enumerated() {
                xVals.append("\(model.hour.ks.format("%02d")):\(model.minute.ks.format("%02d"))")
                yVals.append(BarChartDataEntry(value: Double(model.amount), xIndex: index))
                water = water + model.amount
            }
        }
        waterCycleView.water = CGFloat(water)
        setUpChartData(xVals,yVals: yVals)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.commitCalendarViewUpdate()
    }

}
extension WaterViewController {
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
            return [CBUUID(string: "FFE0")]
        }
    }
    override func characteristicUUIDs(_ service: CBUUID) -> [CBUUID]? {
        //监听的通道
        if service.uuidString == "FFE0" {
            return [CBUUID(string: "FFE1")]
        }
        return nil
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard let data = characteristic.value else {
            return
        }
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        if bytes[0] == 0x55 {
            if bytes[1] == 0x00 {

            }
        }

    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

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
    }
}
