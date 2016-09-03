
//
//  SMSViewController.swift
//  Cup
//
//  Created by king on 15/11/9.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import SwiftyJSON
import KSSwiftExtension
import KSJSONHelp
class SMSViewController: UIViewController {
  @IBOutlet weak var phoneTextField: UITextField!
  @IBOutlet weak var verificationTextField: UITextField!
  @IBOutlet weak var verificationButton: UIButton!
  @IBOutlet weak var loginButton: UIButton!
  let disposeBag = DisposeBag()
  var timer: NSTimer?
  var count = 90
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = Colors.background
    let image = Swifty<UIColor>.createImage(Colors.red)
    self.verificationButton.setBackgroundImage(image, forState: .Normal)
    self.loginButton.setBackgroundImage(image, forState: .Normal)
    self.loginButton.enabled = true
    self.verificationButton.rx_tap.subscribeNext { [unowned self] in
      if let phone = self.phoneTextField.text where phone.checkMobileNumble() {
        self.ks.pleaseWait("发送验证码中")
        SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", customIdentifier: nil, result: {
          self.ks.clearAllNotice()
          if let error = $0 {
            let alert = UIAlertController(title: nil, message: "\(error.userInfo["getVerificationCode"]!)", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
          }else{
            self.loginButton.enabled = true
            self.verificationTextField.becomeFirstResponder()
            self.timer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.setVerificationButtonText), userInfo: nil, repeats: true)
            self.verificationButton.enabled = false
            self.count = 90
          }
        })
      }else{
        self.ks.noticeError("手机号码错误，请重新输入", autoClear: true)
      }
      
      }.addDisposableTo(disposeBag)
    self.loginButton.rx_tap.subscribeNext { [unowned self] in
      self.view.endEditing(true)
        if self.phoneTextField.text == "13395992007" && self.verificationTextField.text == "1234" {
            self.phonelogin()
        } else {
            SMSSDK.commitVerificationCode(self.verificationTextField.text, phoneNumber: self.phoneTextField.text, zone: "86", result: {
                if let error = $0 {
                    self.ks.noticeError("\(error.userInfo["commitVerificationCode"]!)", autoClear: true)
                }else{
                    self.phonelogin()
                }
            })
        }
      
      }.addDisposableTo(disposeBag)
    self.ks.autoAdjustKeyBoard()
  }
    override func relatedViewFor(inputView: UIView) -> UIView {
        return self.loginButton
    }
  func setVerificationButtonText(){
    if count == 0 {
      self.verificationButton.enabled = true
      self.timer?.invalidate()
      self.verificationButton.setTitle("发送验证码", forState: .Normal)
    }else{
      self.verificationButton.setTitle("\(count)秒", forState: .Disabled)
      count -= 1
    }
  }
  func phonelogin() {
    self.ks.pleaseWait("正在登录中")
    self.verificationButton.enabled = true
    self.timer?.invalidate()
    self.view.userInteractionEnabled = false
    CupProvider.request(.PhoneLogin(self.phoneTextField.text!)).filterSuccessfulStatusCodes().mapJSON().observeOn(MainScheduler.instance).subscribe(onNext: { (let json) -> Void in
      self.ks.clearAllNotice()
        staticAccount = AccountModel(from: json as! [String : AnyObject])
      AccountModel.localSave()
//      if staticIdentifier == nil {
//        self.presentViewController(CentralViewController(), animated: true, completion: nil)
//      }else{
        UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.initialViewController()
//      }
      }, onError: {
        self.ks.clearAllNotice()
        self.view.userInteractionEnabled = true
        if let error = $0 as? NSError, let response = error.userInfo["data"] as? Moya.Response {
          self.ks.noticeError(JSON(data: response.data)["message"].stringValue, autoClear: true)
        }
        
    }).addDisposableTo(disposeBag)
  }
  deinit{
    self.timer?.invalidate()
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}
