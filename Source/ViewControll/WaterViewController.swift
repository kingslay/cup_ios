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
        dateButton.snp.makeConstraints { (make) in
            make.top.equalTo(waterCycleView.ks.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        view.addSubview(chartView)
        chartView.snp.makeConstraints { (make) in
            make.top.equalTo(dateButton.snp.bottom)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-10)
        }
        let tapGesture = UITapGestureRecognizer()
        self.chartView.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.subscribe(onNext: { [unowned self](_) in
            let vc = WaterHistoryViewController()
            vc.currentDate = self.currentDate
            self.navigationController?.ks.pushViewController(vc)
        }).addDisposableTo(self.ks.disposableBag)
        calendarView = CalendarView(frame: view.bounds)
        view.addSubview(calendarView)
        calendarView.ks.top(view.ks.bottom)
        dateButton.rx.tap.subscribe(onNext: { [unowned self]_ in
            UIView.animate(withDuration: 0.35, animations: {
                self.calendarView.ks.bottom(self.view.ks.bottom)
            })
            }).addDisposableTo(ks.disposableBag)
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
extension WaterViewController {
    func setUpCentral() {
        self.central = CBCentralManager(delegate: self, queue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(synchronizeClock), name: .synchronizeClock, object: nil)
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
            //同步时间
            let data = NSMutableData()
            let date = Date()
            var array: [UInt8] = [0x66,0x02,0x00,UInt8(date.ks.hour),UInt8(date.ks.minute),0x0a]
            array.append(array[1]+array[2]+array[3]+array[4]+array[5])
            array.append(0xbb)
            data.ks.appendUInt8(array)
            self.peripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)
            synchronizeClock()
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
        //喝水量
        if bytes[0] == 0x55 {
            if bytes[1] == 0x01 {
                let amount = Int(bytes[2])
                let date = Date().ks.date(fromValues:[.hour:Int(bytes[3]),.minute:Int(bytes[4])])
                WaterModel.save(date, amount: amount)
                //确认喝水量
                var array: [UInt8] = [0x55,0x01,0x01,0x00]
                array.append(array[1]+array[2]+array[3])
                array.append(0xaa)
                let data = NSMutableData()
                data.ks.appendUInt8(array)
                self.peripheral?.writeValue(data as Data, for: characteristic, type: .withoutResponse)
            }
        } else if bytes[0] == 0x77 {
            if bytes[1] == 0x03 {
                switch bytes[2] {
                case 0x00:
                    waterCycleView.batteryRate = 01
                case 0x01:
                    waterCycleView.batteryRate = 25
                case 0x02:
                    waterCycleView.batteryRate = 50
                case 0x04:
                    waterCycleView.batteryRate = 75
                case 0x08:
                    waterCycleView.batteryRate = 100
                default:
                    waterCycleView.batteryRate = 100
                }
                //确认电量
                var array: [UInt8] = [0x77,0x03,0x01,0x00]
                array.append(array[1]+array[2]+array[3])
                array.append(0xcc)
                let data = NSMutableData()
                data.ks.appendUInt8(array)
                self.peripheral?.writeValue(data as Data, for: characteristic, type: .withoutResponse)
            }
        }

    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?){
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
    //同步闹钟时间
    func synchronizeClock() {
        if let characteristic = self.characteristic.value {
            if let models = ClockModel.fetch(dic:["open":true]) , models.count > 0 {
                for (index, model) in models.enumerated() {
                    var array: [UInt8] = [0x66,0x02,UInt8(index+1),UInt8(model.hour),UInt8(model.minute),0x00]
                    array.append(array[1]+array[2]+array[3]+array[4]+array[5])
                    array.append(0xbb)
                    let data = NSMutableData()
                    data.ks.appendUInt8(array)
                    self.peripheral?.writeValue(data as Data, for: characteristic, type: .withResponse)

                }
            }
        }
    }
}
