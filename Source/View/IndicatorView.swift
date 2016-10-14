//
//  IndicatorView.swift
//  Cup
//
//  Created by kingslay on 15/11/9.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
open class IndicatorView: UIView {
    let ovalLayer = CAShapeLayer()
    var ovalPathSmall: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: self.ks.centerX, y: self.ks.centerY, width: 0.0, height: 0.0))
    }
    
    var ovalPathLarge: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: self.ks.centerX-100, y: self.ks.centerY-100, width: 200, height: 200))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Colors.white
        let label1 = UILabel()
        label1.text = "搜索智能水杯"
        label1.font = UIFont.systemFont(ofSize: 23)
        label1.sizeToFit()
        label1.textColor = Colors.red
        self.addSubview(label1)
        label1.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(0)
            make.centerY.equalTo(-160)
        }
        let label2 = UILabel()
        label2.text = "请将手机靠近智能水杯"
        label2.font = UIFont.systemFont(ofSize: 12)
        label2.sizeToFit()
        label2.textColor = Colors.red
        self.addSubview(label2)
        label2.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(0)
            make.top.equalTo(label1.snp_bottom).offset(20)
        }
        let circularView = UIView()
        circularView.backgroundColor = Swifty<UIColor>.colorFrom("#e7716b")
        self.addSubview(circularView)
        circularView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(5)
            make.height.equalTo(5)
        }
        circularView.layer.cornerRadius = 2.5
        ovalLayer.fillColor = Swifty<UIColor>.colorFrom("#f4bdba").cgColor
        ovalLayer.path = ovalPathSmall.cgPath
        ovalLayer.opacity = 0.1
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func startAnimating()
    {
        self.isHidden = false
        self.layer.addSublayer(ovalLayer)
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathSmall.cgPath
        expandAnimation.toValue = ovalPathLarge.cgPath
        expandAnimation.duration = 2
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = true
        expandAnimation.repeatCount = 1000
        ovalLayer.add(expandAnimation, forKey: nil)

    }
    open func stopAnimating()
    {
        self.isHidden = true
        ovalLayer.removeAllAnimations()
    }

}
