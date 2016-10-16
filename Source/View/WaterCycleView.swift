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
    ///电量
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
    fileprivate var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = self.progress;
            gradientLayer.mask = self.progressLayer
            let text = "\(Int(progress*100.0))%"
            let attributedText = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 30),NSForegroundColorAttributeName: Colors.pink])
            attributedText.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 18)], range: NSMakeRange(text.length-1, 1))
            waterRate1Label.attributedText = attributedText
            waterRateLabel.text = "完成\(text)"
        }
    }
    fileprivate let waterRateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .center
        label.textColor = Colors.red
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    fileprivate let waterRate1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Colors.pink
        label.font = UIFont.systemFont(ofSize: 30)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    fileprivate let waterLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .center
        label.textColor = Colors.red
        label.font = UIFont.systemFont(ofSize: 49)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    fileprivate let water1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Colors.pink
        label.font = UIFont.systemFont(ofSize: 30)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    fileprivate let waterplanLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .center
        label.textColor = Colors.pink
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "目标123456ml"
        label.sizeToFit()
        return label
    }()
    fileprivate let waterplan1Label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Colors.pink
        label.font = UIFont.systemFont(ofSize: 30)
        label.text = "目标123456ml"
        label.sizeToFit()
        return label
    }()
    fileprivate let batteryRateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.textAlignment = .center
        label.textColor = UIColor.ks.colorFrom("#7dd833")
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "1234567890"
        label.sizeToFit()
        return label
    }()
    fileprivate let batteryRateImageView = UIImageView(image: R.image.icon_Battery_charging())
    fileprivate let trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.ks.colorFrom("#ffd1d8").cgColor
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 22
        return layer
    }()
    fileprivate let progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.lineCap = kCALineCapRound
        layer.lineWidth = 22
        layer.strokeEnd = 0
        return layer
    }()
    fileprivate let gradientLayer = CALayer()
    override init(frame: CGRect) {
        var newFrame = CGRect(x: 0, y: 0, width: KS.SCREEN_WIDTH, height: WaterCycleView.CycleHeight)
        if KS.SCREEN_HEIGHT > 568 {
            newFrame = CGRect(x: 0, y: 0, width: KS.SCREEN_WIDTH, height: WaterCycleView.CycleHeight+100)
        }
        super.init(frame: newFrame)
        if KS.SCREEN_HEIGHT > 568 {
            let label = UILabel()
            label.textColor = Colors.pink
            label.font = UIFont.systemFont(ofSize: 15)
            label.text = "饮水目标"
            label.sizeToFit()
            addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(25)
                make.centerX.equalTo(self)
            }
            addSubview(waterplan1Label)
            waterplan1Label.snp.makeConstraints { (make) in
                make.top.equalTo(label.snp.bottom).offset(10)
                make.centerX.equalTo(label)
            }
            let label1 = UILabel()
            label1.textColor = Colors.pink
            label1.font = UIFont.systemFont(ofSize: 15)
            label1.text = "今日喝水"
            label1.sizeToFit()
            addSubview(label1)
            label1.snp.makeConstraints { (make) in
                make.top.equalTo(label)
                make.right.equalTo(label.snp.left).offset(-62)
            }
            addSubview(water1Label)
            water1Label.snp.makeConstraints { (make) in
                make.top.equalTo(waterplan1Label)
                make.centerX.equalTo(label1)
            }
            let label2 = UILabel()
            label2.textColor = Colors.pink
            label2.font = UIFont.systemFont(ofSize: 15)
            label2.ks.top(25)
            label2.text = "完成计划"
            label2.sizeToFit()
            addSubview(label2)
            label2.snp.makeConstraints { (make) in
                make.top.equalTo(label)
                make.left.equalTo(label.snp.right).offset(62)
            }
            addSubview(waterRate1Label)
            waterRate1Label.snp.makeConstraints { (make) in
                make.top.equalTo(waterplan1Label)
                make.centerX.equalTo(label2)
            }
        }
        let arcCenter = CGPoint(x: center.x, y: self.frame.height-WaterCycleView.CycleHeight/2)
        let path = UIBezierPath(arcCenter: arcCenter, radius: WaterCycleView.CycleHeight/2-trackLayer.lineWidth, startAngle: CGFloat(-240*M_PI/180), endAngle: CGFloat(60*M_PI/180), clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
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
        gradientLayer1.colors = [UIColor.ks.colorFrom("#da251c").cgColor,UIColor.ks.colorFrom("#ff9958").cgColor]
        gradientLayer1.frame = CGRect(x: 0, y: frame.height-WaterCycleView.CycleHeight, width: self.ks.width/2, height: WaterCycleView.CycleHeight)
        gradientLayer1.locations = [0.5,0.9,1]
        gradientLayer1.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer1.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.addSublayer(gradientLayer1)
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.colors = [UIColor.ks.colorFrom("#ff9958").cgColor,UIColor.ks.colorFrom("#da251c").cgColor]
        gradientLayer2.frame = CGRect(x: self.ks.width/2, y: frame.height-WaterCycleView.CycleHeight, width: self.ks.width/2, height: WaterCycleView.CycleHeight)
        gradientLayer2.locations = [0.1,0.5,1]
        gradientLayer2.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer2.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.addSublayer(gradientLayer2)
        gradientLayer.mask = self.progressLayer
        self.layer.addSublayer(gradientLayer)
    }

}
