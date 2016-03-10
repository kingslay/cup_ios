//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
var b:[UInt8] = [0x3a,0x01,0x20]
var d = NSData(bytes: b, length: 3)
d
let bytes = UnsafePointer<UInt8>(d.bytes)
bytes[0]
bytes[1]
bytes[2]


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
let animation = CABasicAnimation(keyPath: "strokeStart")
animation.fromValue = 0.5
animation.toValue = 0
animation.duration = 2

let animation2 = CABasicAnimation(keyPath: "strokeEnd")
animation2.fromValue = 0.5
animation2.toValue = 1
animation2.duration = 2
//animation.autoreverses = true

layer.addAnimation(animation, forKey: "")
layer.addAnimation(animation2, forKey: "")

let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
container.layer.addSublayer(layer)
XCPlaygroundPage.currentPage.liveView = container
import Foundation
class CustomThread: NSThread {
    var myTimer: NSTimer!
    init(myTimer: NSTimer) {
        self.myTimer = myTimer
    }
    override func main() {
        autoreleasepool{
            let runloop = NSRunLoop.currentRunLoop()
            runloop.addTimer(self.myTimer, forMode: NSRunLoopCommonModes)
            print(NSThread.isMultiThreaded())
            runloop.runUntilDate(NSDate(timeIntervalSinceNow: 5))
        }
    }
}
class TestThread: NSObject {
    func testTimerSource() {
        let fireTimer = NSDate(timeIntervalSinceNow: 1)
        let myTimer = NSTimer(fireDate: fireTimer, interval: 0.5, target: self, selector: "timerTask", userInfo: nil, repeats: true)
        let customThread = CustomThread(myTimer: myTimer)
        customThread.start()
        sleep(5)
    }
    func timerTask() {
        print("Fire timer...")
    }
}
let testThread = TestThread()
testThread.testTimerSource()
let f: Float80
let d1 = 1e-5
d1 == 0.0

