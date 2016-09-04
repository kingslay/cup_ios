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
import Async
import KSSwiftExtension
import Charts
import SwiftDate
class WaterViewController: ShareViewController {
    var central: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristic: Variable<CBCharacteristic?> = Variable(nil)
    var selectedIndex: Int?
    var timer: NSTimer?
    var durationTimer: NSTimer?
    var dateButton = UIButton()
    var waterCycleView: WaterCycleView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCentral()
        self.waterCycleView = WaterCycleView(frame: CGRect(x: 0, y: 0, width: KS.SCREEN_WIDTH, height: 230))
        waterCycleView.waterplan = CGFloat(staticAccount?.waterplan?.floatValue ?? 2300)
        waterCycleView.water = 1200
        waterCycleView.batteryRate = 100
        view.addSubview(waterCycleView)
        dateButton.setImage(R.image.icon_calendar(), forState: .Normal)
        dateButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        dateButton.setTitleColor(Colors.pink, forState: .Normal)
        dateButton.setTitle(NSDate().ks.stringFromFormat(" yyyy年MM月dd日"), forState: .Normal)
        dateButton.sizeToFit()
        view.addSubview(dateButton)
        dateButton.snp_makeConstraints { (make) in
            make.top.equalTo(waterCycleView.ks.bottom)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        view.addSubview(chartView)
        chartView.snp_makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(dateButton.snp_bottom)
            make.bottom.equalToSuperview()
        }
        let tapGesture = UITapGestureRecognizer()
        self.chartView.addGestureRecognizer(tapGesture)
        tapGesture.rx_event.subscribeNext{ [unowned self](_) in
            self.navigationController?.ks.pushViewController(WaterHistoryViewController())
        }.addDisposableTo(self.ks.disposableBag)
        self.setUpChartData()
    }
    func setUpChartData() {
        let xVals = (0..<24).map{String($0) as? String}
        let yVals = (0..<24).map{BarChartDataEntry(value: Double(arc4random_uniform(100)), xIndex: $0)}
        if let set = chartView.data?.dataSets[0] as? BarChartDataSet {
            set.yVals = yVals
            chartView.data?.xVals = xVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            let set = LineChartDataSet(yVals: yVals, label: nil)
            set.mode = .CubicBezier
            set.lineDashLengths = [5, 2.5]
            set.highlightLineDashLengths = [5, 2.5]
            set.setColor(Colors.red)
            set.setCircleColor(Colors.red)
            set.lineWidth = 1.0
            set.circleRadius = 2.0
            let gradientColors = [Colors.white.CGColor,Colors.red.CGColor]
            set.fillAlpha = 1
            set.fill = ChartFill.fillWithLinearGradient(CGGradientCreateWithColors(nil, gradientColors, nil)!, angle: 90)
            set.drawFilledEnabled = true
            set.drawValuesEnabled = false
            let data = LineChartData(xVals: xVals, dataSets: [set])
            chartView.data = data
        }
    }

}
extension WaterViewController {
    func setUpCentral() {
        self.central = CBCentralManager(delegate: self, queue: nil)
    }
    override func scanForPeripherals(central: CBCentralManager) {
        if let staticIdentifier = staticIdentifier, identifier = NSUUID(UUIDString: staticIdentifier) {
            self.durationTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(durationTimerElapsed), userInfo: nil, repeats: false)
            let peripherals = self.central.retrievePeripheralsWithIdentifiers([identifier])
            if peripherals.count > 0 {
                didDiscoverPeripheral(peripherals[0])
            }
        }else{
            alterCentralViewController()
        }
    }
    @objc private func durationTimerElapsed() {
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        if self.characteristic.value == nil {
            let alertController = UIAlertController(title: "找不到之前设定的蓝牙的设备，是否要重新扫描，设定蓝牙设备", message: nil, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "是", style: UIAlertActionStyle.Default){
                (action: UIAlertAction!) -> Void in
                self.navigationController?.pushViewController(CentralViewController(), animated: true)
            }
            let cancelAction = UIAlertAction(title: "否", style: .Cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)

        }
    }

    override func didDiscoverPeripheral(peripheral: CBPeripheral) {
        if peripheral.identifier.UUIDString == staticIdentifier {
            self.peripheral = peripheral
            self.central.connectPeripheral(peripheral, options: nil)
            self.central.stopScan()
        }
    }
    override func didDiscoverCharacteristicsForService(characteristic: CBCharacteristic) {
        if characteristic.properties.contains([.Notify]) {
            self.peripheral?.setNotifyValue(true, forCharacteristic: characteristic)
        }
        if characteristic.properties.contains([.Write]) {
            self.characteristic.value = characteristic
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60*5, target: self, selector: #selector(askTemperature), userInfo: nil, repeats: true)
            self.timer?.fire()
            //连接通过之后，发送一下。让杯子叫一下
            let data = NSMutableData()
            data.ks.appendUInt8(0x3a)
            data.ks.appendUInt8(0x11)
            data.ks.appendUInt16(0x00)
            data.ks.appendUInt16(0x00)
            data.ks.appendUInt8(0x11)
            data.ks.appendUInt8(0x0a)
            self.peripheral?.writeValue(data, forCharacteristic: characteristic, type: .WithResponse)
        }
    }

    override var serviceUUIDs: [CBUUID]? {
        get{
            return [CBUUID(string: "FFE0")]
        }
    }
    override func characteristicUUIDs(service: CBUUID) -> [CBUUID]? {
        //监听的通道
        if service.UUIDString == "FFE0" {
            return [CBUUID(string: "FFE1")]
        }
        return nil
    }
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard let data = characteristic.value else {
            return
        }
        let bytes = UnsafePointer<UInt8>(data.bytes)
        if bytes[0] == 0x55 {
            if bytes[1] == 0x00 {

            }
        }

    }
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

    }

    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        self.timer?.invalidate()
        self.timer = nil
        self.durationTimer?.invalidate()
        self.durationTimer = nil
        if let _ = error {
            self.central.connectPeripheral(peripheral, options: nil)
        }
    }
    func alterCentralViewController() {
        let alertController = UIAlertController(title: "您还没有关联水杯设备,是否现在进行关联", message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "是", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            self.navigationController?.pushViewController(CentralViewController(), animated: true)
        }
        let cancelAction = UIAlertAction(title: "否", style: .Cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)

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
            self.peripheral?.writeValue(data, forCharacteristic: characteristic, type: .WithResponse)
        }
    }
}