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
class WaterViewController: ShareViewController {
    var waterCycleView: WaterCycleView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var frame = self.view.frame
        frame.size.height = 200
        self.waterCycleView = WaterCycleView(frame: frame)
        self.waterCycleView.progress = 0.8
        self.view.addSubview(self.waterCycleView)
        self.view.addSubview(self.chartView)
        self.chartView.snp_makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalToSuperview()
        }
        let tapGesture = UITapGestureRecognizer()
        self.chartView.addGestureRecognizer(tapGesture)
        tapGesture.rx_event.subscribeNext{ [unowned self](_) in
            self.navigationController?.pushViewController(WaterHistoryViewController())
        }.addDisposableTo(self.ks_disposableBag)
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
            set.setColor(UIColor.blackColor())
            set.setCircleColor(UIColor.blackColor())
            set.lineWidth = 1.0
            set.circleRadius = 3.0
            let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").CGColor,ChartColorTemplates.colorFromString("#ffff0000").CGColor]
            set.fillAlpha = 1
            set.fill = ChartFill.fillWithLinearGradient(CGGradientCreateWithColors(nil, gradientColors, nil)!, angle: 90)
            set.drawFilledEnabled = true
            set.drawValuesEnabled = false
            let data = LineChartData(xVals: xVals, dataSets: [set])
            chartView.data = data
        }
    }

}
