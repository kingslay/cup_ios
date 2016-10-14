//
//  WaterplanViewController.swift
//  Cup
//
//  Created by king on 16/9/4.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
class WaterplanViewController: UIViewController {
    @IBOutlet weak var titileLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    @IBOutlet weak var rulerView: KSRulerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.bar_icon_(), style: .plain, target: self, action: #selector(complete))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if rulerView.delegete == nil {
            rulerView.delegete = self
            rulerView.showRulerScrollViewWithCount(300, beginValue: 500, endValue: 6500)
            var currentValue = staticAccount!.calculateProposalWater()
            if let waterplan = staticAccount?.waterplan {
                currentValue = Int(waterplan)
            }
            rulerView.currentValue = CGFloat(currentValue)
            let attributedText = NSMutableAttributedString(string: "您每天需要的饮水量（根据您的个人信息）推荐值约为 \(currentValue) ml",attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16),NSForegroundColorAttributeName: Colors.red])
            attributedText.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 18)], range: NSMakeRange(24, attributedText.length-24))
            titileLabel.attributedText = attributedText
        }
    }
    func complete() {
        staticAccount?.waterplan = Int(rulerView.currentValue) as NSNumber?
        self.navigationController?.popViewController(animated: false)
    }
}
extension WaterplanViewController: KSRulerDelegate {
    func ruler(_ value: CGFloat){
        waterLabel.text = "\(Int(value))ml"
    }
}
