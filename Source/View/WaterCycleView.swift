//
//  WaterCycleView.swift
//  Cup
//
//  Created by king on 16/8/14.
//  Copyright © 2016年 king. All rights reserved.
//

import UIKit
import KSSwiftExtension
class WaterCycleView: UIView {
    var progress: CGFloat {
        didSet{
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
            CATransaction.setAnimationDuration(0.5)
            self.progressLayer.strokeEnd = progress/100.0;
            CATransaction.commit()
        }
    }
    let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .Center
        label.textColor = .blackColor()
        label.text = "Hello, World!"
        return label
    }()
    let trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.redColor().CGColor
        layer.opacity = 0.25
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 10
        return layer
    }()
    let progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 10
        layer.strokeEnd = 0
        return layer
    }()
    override init(frame: CGRect) {
        self.progress = 50
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.label.center = CGPoint(x: self.ks_width/2, y: self.ks_height/2)
        self.addSubview(self.label)
         let path = UIBezierPath(arcCenter: center, radius: 90, startAngle: CGFloat(-210*M_PI/180), endAngle: CGFloat(30.0*M_PI/180), clockwise: true)
        self.trackLayer.path = path.CGPath
        self.progressLayer.path = path.CGPath
        self.layer.addSublayer(self.trackLayer)
        self.layer.addSublayer(self.progressLayer)
        self.progressLayer.strokeEnd = progress/100.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
