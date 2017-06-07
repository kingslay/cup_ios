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
import Async
class WaterViewController: ShareViewController {
    var central: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristic: Variable<CBCharacteristic?> = Variable(nil)
    var selectedIndex: Int?
    var durationTimer: Timer?
    var timer: Timer?
    lazy var dateButton = UIButton()
    var calendarView: CalendarView!
    var waterCycleView: WaterCycleView!
    var waterData: Data?
    //发送结束码的时间。要超过5秒才发送结束码
    var writeDate: Date?
    var currentDate = Foundation.Date() {
        didSet{
            self.dateButton.setTitle(currentDate.ks.string(fromFormat:"yyyy年MM月dd日"), for: UIControlState())
            self.setUpChartData(currentDate)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icon_add(), style: .plain, target: self, action: #selector(addWater))
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
            self.currentDate = date
        }
        currentDate = Foundation.Date()
//        handleWaterData(Data([0x55,0x01,0x02,0x14,0x25,0x00,0x3c,0xaa,0x55,0x01,0xfe
//            ,0x14,0x24,0x00,0x37,0xaa,0x55,0x01,0x18,0x14,] as [UInt8]))
//        handleWaterData(Data([0x27,0x00,0x54,0xaa] as [UInt8]))
//        handleWaterData(Data([0x55,0x01,0x02,0x14,0x20,0x0a,0x41,0xaa] as [UInt8]))
//        Async.main(after: 1) { [unowned self] _ in
//            self.handleWaterData(Data([0x55,0x01,0x02,0x14,0x20,0x0a,0x41,0xaa] as [UInt8]))
//        }
//        Async.main(after: 6) { [unowned self] _ in
//            self.handleWaterData(Data([0x55,0x01,0x02,0x14,0x20,0x0a,0x41,0xaa] as [UInt8]))
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpChartData(currentDate)
        waterCycleView.waterplan = CGFloat(staticAccount?.waterplan?.intValue ?? staticAccount!.calculateProposalWater())
    }
    func addWater() {
        let vc = R.nib.addWaterViewController.firstView(owner: nil)!
        vc.addModel = { [unowned self] _ in
            self.setUpChartData(self.currentDate)
        }
        self.navigationController!.ks.pushViewController(vc)
    }
    func setUpChartData(_ date: Foundation.Date) {
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
        self.timer?.invalidate()
        self.timer = nil
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        if let peripheral = self.peripheral {
            self.central.cancelPeripheralConnection(peripheral)
        }
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
            self.timer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(ask), userInfo: nil, repeats: true)
            self.timer?.fire()
            //同步时间
            let date = Date()
            var array: [UInt8] = [0x66,0x02,0x0,UInt8(date.ks.hour),UInt8(date.ks.minute),0x0a]
            array.append(array[1]&+array[2]&+array[3]&+array[4]&+array[5])
            array.append(0xbb)
            self.peripheral?.writeValue(Data(array), for: characteristic, type: .withResponse)
            self.synchronizeClock()
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
        handleWaterData(data)
    }
    func handleWaterData(_ data: Data) {
        if waterData != nil {
            waterData!.append(data)
        } else if data[0] == 0x55 && data.count >= 8 {//喝水量
            if data[1] == 0x01 {
                waterData = data
            }
        } else if data[0] == 0x77 && data.count >= 6 {
            if data[1] == 0x03 {
                let check = data[1] &+ data[2] &+ data[3]
                guard check == data[4] else {
                    write(value:[0x77,0x03,0x00,0x00,0x03,0xcc])
                    return
                }
                switch data[2] {
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
                write(value:[0x77,0x03,0x01,0x00,0x04,0xcc])
            }
        } else if data[0] == 0x66 {
            print(data)
        }
        if let waterData = waterData {
            let count = waterData.count
            if (count >= 8 && waterData[count-3] == 0x0a) {
                defer {
                }
                for i in 0..<count/8 {
                    let check = waterData[8*i+1] &+ waterData[8*i+2] &+ waterData[8*i+3] &+ waterData[8*i+4] &+ waterData[8*i+5]
                    guard check == waterData[8*i+6] else {
                        write(value:[0x55,0x01,0x00,0x00,0x01,0xAA])
                        self.waterData = nil
                        return
                    }
                    let amount = Int(waterData[8*i+2])
                    let hour = Int(waterData[8*i+3])
                    let minute = Int(waterData[8*i+4])
                    let date = Date().ks.date(fromValues:[.hour:hour,.minute:minute,.second:0])
                    WaterModel.save(date, amount: amount)

                }
                setUpChartData(currentDate)
                self.waterData = nil
                //确认喝水量,要隔5秒以上才能再次发送喝水量
                if let date = writeDate {
                    let interval = Date().timeIntervalSince(date)
                    if interval < 5 {
                        return
                    }
                }
                write(value:[0x55,0x01,0x01,0x00,0x02,0xAA])
                writeDate = Date()
            }
        }

    }
    func write(value: [UInt8]) {
        if let characteristic = self.characteristic.value {
            self.peripheral?.writeValue(Data(value), for: characteristic, type: .withoutResponse)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?){
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
    //同步闹钟时间
    func synchronizeClock() {
        if let characteristic = self.characteristic.value {
            if let models = ClockModel.fetch(dic:["open":1]) , models.count > 0 {
                Async.background {
                    for (index, model) in models.enumerated() {
                        guard index < 14 else {
                            break
                        }
                        Thread.sleep(forTimeInterval: 1)
                        var array: [UInt8] = [0x66,0x02,UInt8(index+1),UInt8(model.hour),UInt8(model.minute),0x00]
                        array.append(array[1]&+array[2]&+array[3]&+array[4]&+array[5])
                        array.append(0xbb)
                        self.peripheral?.writeValue(Data(array), for: characteristic, type: .withResponse)
                    }
                }
            } else {
                //取消闹钟
                self.peripheral?.writeValue(Data([0x66,0x02,0x00,0x00,0x00,0xa0,0xa2,0xbb] as [UInt8]), for: characteristic, type: .withResponse)
            }
        }
    }
    func ask(){
        askPower()
    }
    //查询电量
    func askPower() {
        if let characteristic = self.characteristic.value {
            self.peripheral?.writeValue(Data([0xdd,0x11,0x03,0x00,0x14,0x88] as [UInt8]), for: characteristic, type: .withResponse)
        }

    }
}
