//
//  ShareViewController.swift
//  Cup
//
//  Created by king on 16/8/13.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import Charts
import KSSwiftExtension
class ShareViewController: UIViewController {
    let chartView: LineChartView = {
        let chartView = LineChartView(frame: CGRect(x: 0, y:0, width: KS.SCREEN_WIDTH, height: KS.SCREEN_HEIGHT/2))
        chartView.descriptionText = "";
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
//        chartView.drawBarShadowEnabled = false
        chartView.xAxis.labelPosition = .Bottom
        chartView.xAxis.labelTextColor = Colors.pink
        chartView.xAxis.drawGridLinesEnabled = false
        let valueFormatter = NSNumberFormatter()
        valueFormatter.maximumFractionDigits = 1
        valueFormatter.positiveSuffix = "ml"
        chartView.leftAxis.valueFormatter = valueFormatter
        chartView.leftAxis.axisMinValue = 0
        chartView.leftAxis.labelTextColor = Colors.pink
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        return chartView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.background
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_share(), style: .Plain, target: self, action: #selector(showShareSheet(_:)))
    }

    func showShareSheet(view: UIView) {
        let sheet = R.nib.shareSheet.firstView(owner: nil)
        sheet?.showIn(self.view)
    }
    func setUpChartData(xVals:[String?],yVals:[BarChartDataEntry]) {
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
