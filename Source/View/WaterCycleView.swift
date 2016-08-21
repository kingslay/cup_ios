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
    var progress: CGFloat = 0 {
        didSet {
            self.progressLayer.strokeEnd = self.progress;
            gradientLayer.mask = self.progressLayer
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
    let gradientLayer = CALayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.label.center = CGPoint(x: self.ks.width/2, y: self.ks.height/2)
        self.addSubview(self.label)
        let path = UIBezierPath(arcCenter: center, radius: 90, startAngle: CGFloat(-210*M_PI/180), endAngle: CGFloat(30.0*M_PI/180), clockwise: true)
        self.trackLayer.path = path.CGPath
        self.progressLayer.path = path.CGPath
        self.layer.addSublayer(self.trackLayer)
        self.setUpGradientLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpGradientLayer() {
        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.colors = [UIColor.blueColor().CGColor,UIColor.yellowColor().CGColor]
        gradientLayer1.frame = CGRect(x: 0, y: 0, width: self.ks.width/2, height: self.ks.height)
        gradientLayer1.locations = [0.5,0.9,1]
        gradientLayer1.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer1.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.addSublayer(gradientLayer1)
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.colors = [UIColor.blackColor().CGColor,UIColor.yellowColor().CGColor]
        gradientLayer2.frame = CGRect(x: self.ks.width/2, y: 0, width: self.ks.width/2, height: self.ks.height)
        gradientLayer2.locations = [0.1,0.5,1]
        gradientLayer2.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer2.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.addSublayer(gradientLayer2)
        gradientLayer.mask = self.progressLayer
        self.layer.addSublayer(gradientLayer)
    }

}
