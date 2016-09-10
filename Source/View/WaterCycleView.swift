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
    static var CycleHeight:CGFloat = 230
    var water: CGFloat = 0 {
        didSet {
            waterLabel.text = "\(Int(water))"
            water1Label.text = "\(Int(water))"
            progress = water/waterplan
        }
    }
    var waterplan: CGFloat = 2300 {
        didSet {
            waterplanLabel.text = "目标 \(Int(waterplan))ml"
            waterplan1Label.text = "\(Int(waterplan))"
            progress = water/waterplan
        }
    }
    var batteryRate: NSInteger = 100 {
        didSet {
            if batteryRate >= 100 {
                self.batteryRateLabel.text = "100%"
                self.batteryRateImageView.image = R.image.icon_Battery_charging()
            } else if batteryRate > 20 {
                self.batteryRateLabel.text = "\(batteryRate)%"
                self.batteryRateImageView.image = R.image.icon_Battery_hight()
            } else {
                self.batteryRateLabel.text = "\(batteryRate)%"
                self.batteryRateImageView.image = R.image.icon_Battery_low()
            }
        }
    }
    private var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = self.progress;
            gradientLayer.mask = self.progressLayer
            waterRate1Label.text = "\(Int(progress*100.0))％"
            waterRateLabel.text = "完成\(waterRate1Label.text!)"
        }
    }
    private let waterRateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .Center
        label.textColor = Colors.red
        label.font = UIFont.systemFontOfSize(18)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    private let waterRate1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.textColor = Colors.pink
        label.font = UIFont.systemFontOfSize(30)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    private let waterLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .Center
        label.textColor = Colors.red
        label.font = UIFont.systemFontOfSize(49)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    private let water1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.textColor = Colors.pink
        label.font = UIFont.systemFontOfSize(30)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    private let waterplanLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .Center
        label.textColor = Colors.pink
        label.font = UIFont.systemFontOfSize(18)
        label.text = "目标123456ml"
        label.sizeToFit()
        return label
    }()
    private let waterplan1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.textColor = Colors.pink
        label.font = UIFont.systemFontOfSize(30)
        label.text = "目标123456ml"
        label.sizeToFit()
        return label
    }()
    private let batteryRateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .Center
        label.textColor = Swifty<UIColor>.colorFrom("#7dd833")
        label.font = UIFont.systemFontOfSize(15)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    private let batteryRateImageView = UIImageView(image: R.image.icon_Battery_charging())
    private let trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = Swifty<UIColor>.colorFrom("#ffd1d8").CGColor
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 22
        return layer
    }()
    private let progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.blackColor().CGColor
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 22
        layer.strokeEnd = 0
        return layer
    }()
    private let gradientLayer = CALayer()
    override init(frame: CGRect) {
        var newFrame = CGRect(x: 0, y: 0, width: KS.SCREEN_WIDTH, height: WaterCycleView.CycleHeight)
        if KS.SCREEN_HEIGHT > 568 {
            newFrame = CGRect(x: 0, y: 0, width: KS.SCREEN_WIDTH, height: WaterCycleView.CycleHeight+100)
        }
        super.init(frame: newFrame)
        if KS.SCREEN_HEIGHT > 568 {
            let label = UILabel()
            label.textColor = Colors.pink
            label.font = UIFont.systemFontOfSize(15)
            label.text = "饮水目标"
            label.sizeToFit()
            addSubview(label)
            label.snp_makeConstraints { (make) in
                make.top.equalTo(25)
                make.centerX.equalTo(self)
            }
            addSubview(waterplan1Label)
            waterplan1Label.snp_makeConstraints { (make) in
                make.top.equalTo(label.snp_bottom).offset(10)
                make.centerX.equalTo(label)
            }
            let label1 = UILabel()
            label1.textColor = Colors.pink
            label1.font = UIFont.systemFontOfSize(15)
            label1.text = "今日喝水"
            label1.sizeToFit()
            addSubview(label1)
            label1.snp_makeConstraints { (make) in
                make.top.equalTo(label)
                make.right.equalTo(label.snp_left).offset(-62)
            }
            addSubview(water1Label)
            water1Label.snp_makeConstraints { (make) in
                make.top.equalTo(waterplan1Label)
                make.centerX.equalTo(label1)
            }
            let label2 = UILabel()
            label2.textColor = Colors.pink
            label2.font = UIFont.systemFontOfSize(15)
            label2.ks.top(25)
            label2.text = "完成计划"
            label2.sizeToFit()
            addSubview(label2)
            label2.snp_makeConstraints { (make) in
                make.top.equalTo(label)
                make.left.equalTo(label.snp_right).offset(62)
            }
            addSubview(waterRate1Label)
            waterRate1Label.snp_makeConstraints { (make) in
                make.top.equalTo(waterplan1Label)
                make.centerX.equalTo(label2)
            }
        }
        let arcCenter = CGPoint(x: center.x, y: self.frame.height-WaterCycleView.CycleHeight/2)
        let path = UIBezierPath(arcCenter: arcCenter, radius: WaterCycleView.CycleHeight/2-trackLayer.lineWidth, startAngle: CGFloat(-240*M_PI/180), endAngle: CGFloat(60*M_PI/180), clockwise: true)
        trackLayer.path = path.CGPath
        progressLayer.path = path.CGPath
        layer.addSublayer(self.trackLayer)
        setUpGradientLayer()
        waterLabel.center = arcCenter
        addSubview(waterLabel)
        waterRateLabel.ks.bottom(waterLabel.ks.top-5)
        waterRateLabel.ks.centerX(waterLabel.ks.centerX)
        addSubview(waterRateLabel)
        waterplanLabel.ks.top(waterLabel.ks.bottom+5)
        waterplanLabel.ks.centerX(waterLabel.ks.centerX)
        addSubview(waterplanLabel)
        batteryRateLabel.ks.top(waterplanLabel.ks.bottom+5)
        batteryRateLabel.ks.centerX(waterLabel.ks.centerX)
        addSubview(batteryRateLabel)
        batteryRateImageView.ks.top(batteryRateLabel.ks.bottom+3)
        batteryRateImageView.ks.centerX(waterLabel.ks.centerX)
        addSubview(batteryRateImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpGradientLayer() {
        let gradientLayer1 = CAGradientLayer()
        gradientLayer1.colors = [Swifty<UIColor>.colorFrom("#da251c").CGColor,Swifty<UIColor>.colorFrom("#ff9958").CGColor]
        gradientLayer1.frame = CGRect(x: 0, y: frame.height-WaterCycleView.CycleHeight, width: self.ks.width/2, height: WaterCycleView.CycleHeight)
        gradientLayer1.locations = [0.5,0.9,1]
        gradientLayer1.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer1.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.addSublayer(gradientLayer1)
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.colors = [Swifty<UIColor>.colorFrom("#ff9958").CGColor,Swifty<UIColor>.colorFrom("#da251c").CGColor]
        gradientLayer2.frame = CGRect(x: self.ks.width/2, y: frame.height-WaterCycleView.CycleHeight, width: self.ks.width/2, height: WaterCycleView.CycleHeight)
        gradientLayer2.locations = [0.1,0.5,1]
        gradientLayer2.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer2.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.addSublayer(gradientLayer2)
        gradientLayer.mask = self.progressLayer
        self.layer.addSublayer(gradientLayer)
    }

}
