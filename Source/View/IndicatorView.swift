//
//  IndicatorView.swift
//  Cup
//
//  Created by kingslay on 15/11/9.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit

class IndicatorView: UIView {
    let ovalLayer = CAShapeLayer()
    let view = UIView()
    var ovalPathSmall: UIBezierPath {
        return UIBezierPath(ovalInRect: CGRect(x: 50, y: 50, width: 0.0, height: 0.0))
    }
    
    var ovalPathLarge: UIBezierPath {
        return UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 100, height: 100))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.5
        let circularView = UIView()
        circularView.backgroundColor = UIColor.redColor()
        self.addSubview(circularView)
        circularView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(CGSizeMake(2, 2))
        }
        circularView.layer.cornerRadius = 1
        ovalLayer.fillColor = Colors.red.CGColor
        ovalLayer.path = ovalPathSmall.CGPath
        ovalLayer.opacity = 0.5
        self.addSubview(view)
        view.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(CGSizeMake(100, 100))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func startAnimating()
    {
        self.hidden = false
        self.view.layer.addSublayer(ovalLayer)
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
