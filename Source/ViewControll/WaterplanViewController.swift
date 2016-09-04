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
    @IBOutlet weak var rulerView: KSRulerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.bar_icon_(), style: .Plain, target: self, action: #selector(complete))
        rulerView.showRulerScrollViewWithCount(300, beginValue: 900, endValue: 6900)
        rulerView.currentValue = 2300
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    func complete() {
        staticAccount?.waterplan = 2300
        self.navigationController?.popViewControllerAnimated(false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
