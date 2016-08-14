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
            self.setNeedsDisplay()
        }
    }
    let label: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .Center
        label.textColor = .blackColor()
        label.text = "Hello, World!"
        return label
    }()
    override init(frame: CGRect) {
        self.progress = 0.1
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.label.center = CGPoint(x: self.ks_width/2, y: self.ks_height/2)
        self.addSubview(self.label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let ctx = UIGraphicsGetCurrentContext()
        let center = self.center
        let startAngle = -CGFloat(M_PI+M_PI_2)
        let endAngle = startAngle + CGFloat(M_PI*2)*self.progress
        let path = UIBezierPath(arcCenter: center, radius: 90, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        CGContextSetLineWidth(ctx,10)
        UIColor.redColor().setStroke()
        CGContextAddPath(ctx,path.CGPath)
        CGContextStrokePath(ctx);  //渲染
    }

}
