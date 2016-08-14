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
    let chartView: BarChartView = {
        let chartView = BarChartView(frame: CGRect(x: 0, y:0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2))
        chartView.descriptionText = "";
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.xAxis.labelPosition = .Bottom
        chartView.xAxis.drawGridLinesEnabled = false
        let valueFormatter = NSNumberFormatter()
        valueFormatter.maximumFractionDigits = 1
        valueFormatter.positiveSuffix = " ml"
        chartView.leftAxis.valueFormatter = valueFormatter
        chartView.leftAxis.axisMinValue = 0
        chartView.rightAxis.valueFormatter = valueFormatter
        chartView.rightAxis.axisMinValue = 0
        chartView.legend.enabled = false
        return chartView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        var frame = self.view.frame
        frame.size.height = 200
        self.waterCycleView = WaterCycleView(frame: frame)
        self.view.addSubview(self.waterCycleView)
        self.view.addSubview(self.chartView)
        self.chartView.snp_makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)
            make.bottom.equalToSuperview()
        }
        self.setUpChartData()
    }
    func setUpChartData() {
        let xVals = (0..<24).map{String($0) as? String}
        let yVals = (0..<24).map{BarChartDataEntry(value: Double($0), xIndex: $0)}

        if let set = chartView.data?.dataSets[0] as? BarChartDataSet {
            set.yVals = yVals
            chartView.data?.xVals = xVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            let set = BarChartDataSet(yVals: yVals, label: nil)
            set.drawValuesEnabled = false
            let data = BarChartData(xVals: xVals, dataSets: [set])
            chartView.data = data
        }
    }

}
