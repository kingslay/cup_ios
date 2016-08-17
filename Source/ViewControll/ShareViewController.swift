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
        let chartView = LineChartView(frame: CGRect(x: 0, y:0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT/2))
        chartView.descriptionText = "";
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
//        chartView.drawBarShadowEnabled = false
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
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.logo(), style: .Plain, target: self, action: #selector(showShareSheet(_:)))
    }

    func showShareSheet(view: UIView) {
        let sheet = R.nib.shareSheet.firstView(owner: nil)
        sheet?.showIn(self.view)
    }
}
