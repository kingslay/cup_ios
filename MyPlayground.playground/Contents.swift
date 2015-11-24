//: Playground - noun: a place where people can play

import UIKit
import XCPlayground


var str = "Hello, playground"
let startPoint = CGPointMake(50, 300)
let endPoint = CGPointMake(300, 300)
let controlPoint = CGPointMake(170, 200)
let layer = CAShapeLayer()
let path = UIBezierPath()
path.moveToPoint(startPoint)
path.addQuadCurveToPoint(endPoint, controlPoint: controlPoint)
layer.path = path.CGPath
layer.fillColor = UIColor.clearColor().CGColor
layer.strokeColor = UIColor.redColor().CGColor
let animation = CABasicAnimation(keyPath: "strokeEnd")
animation.fromValue = 0
animation.toValue = 1
animation.duration = 2
layer.addAnimation(animation, forKey: "")

let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
container.layer.addSublayer(layer)
container
XCPlaygroundPage.currentPage.liveView = container
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//XCPlaygroundPage.currentPage.finishExecution()
