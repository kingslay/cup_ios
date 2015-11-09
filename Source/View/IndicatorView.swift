//
//  IndicatorView.swift
//  Cup
//
//  Created by kingslay on 15/11/9.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

public class IndicatorView: UIView {
    let ovalLayer = CAShapeLayer()
    var ovalPathSmall: UIBezierPath {
        return UIBezierPath(ovalInRect: CGRect(x: self.ks_centerX, y: self.ks_centerY, width: 0.0, height: 0.0))
    }
    
    var ovalPathLarge: UIBezierPath {
        return UIBezierPath(ovalInRect: CGRect(x: self.ks_centerX-50, y: self.ks_centerY-50, width: 100, height: 100))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.blackColor()
//        self.alpha = 0.5
        let circularView = UIView()
        circularView.backgroundColor = UIColor.redColor()
        self.addSubview(circularView)
        circularView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(2)
            make.height.equalTo(2)
        }
        circularView.layer.cornerRadius = 1
        
        ovalLayer.fillColor = Colors.red.CGColor
        ovalLayer.path = ovalPathSmall.CGPath
        ovalLayer.opacity = 0.1
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func startAnimating()
    {
        self.hidden = false
        self.layer.addSublayer(ovalLayer)
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathSmall.CGPath
        expandAnimation.toValue = ovalPathLarge.CGPath
        expandAnimation.duration = 1.5
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.removedOnCompletion = true
        expandAnimation.repeatCount = 1000
        ovalLayer.addAnimation(expandAnimation, forKey: nil)

    }
    public func stopAnimating()
    {
        self.hidden = true
        ovalLayer.removeAllAnimations()
    }

}
