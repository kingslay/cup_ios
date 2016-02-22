
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
    let image = UIColor.createImageWithColor(Colors.red)
    self.verificationButton.setBackgroundImage(image, forState: .Normal)
    self.loginButton.setBackgroundImage(image, forState: .Normal)
    
    self.verificationButton.rx_tap.subscribeNext { [unowned self] in
      if let phone = self.phoneTextField.text where phone.checkMobileNumble() {
        self.pleaseWait("发送验证码中")
        SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", customIdentifier: nil, result: {
          self.clearAllNotice()
          if let error = $0 {
            let alert = UIAlertController(title: nil, message: "\(error.userInfo["getVerificationCode"]!)", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
          }else{
            self.loginButton.enabled = true
            self.verificationTextField.becomeFirstResponder()
            self.timer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "setVerificationButtonText", userInfo: nil, repeats: true)
            self.verificationButton.enabled = false
            self.count = 90
          }
        })
      }else{
        self.noticeError("手机号码错误，请重新输入", autoClear: true)
      }
      
      }.addDisposableTo(disposeBag)
    self.loginButton.rx_tap.subscribeNext { [unowned self] in
      self.view.endEditing(true)
      SMSSDK.commitVerificationCode(self.verificationTextField.text, phoneNumber: self.phoneTextField.text, zone: "86", result: {
        if let error = $0 {
          self.noticeError("\(error.userInfo["commitVerificationCode"]!)", autoClear: true)
        }else{
          self.phonelogin()
        }
      })
      
      }.addDisposableTo(disposeBag)
    NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillShowNotification).subscribeNext{
      [unowned self] in
      let userInfo: NSDictionary = $0.userInfo!
      let keyboardBounds = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
      let diff = self.loginButton.ks_bottom + keyboardBounds.height - SCREEN_HEIGHT
      if diff > 0 {
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0
        UIView.animateWithDuration(duration, animations: {
          var frame = self.view.frame
          frame.origin.y += diff
          self.view.bounds = frame
        })
      }
      }.addDisposableTo(disposeBag)
    NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillHideNotification).subscribeNext{
      [unowned self] in
      let userInfo: NSDictionary = $0.userInfo!
      let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval ?? 0
      UIView.animateWithDuration(duration, animations: {
        let frame = self.view.frame
        self.view.bounds = frame
      })
      }.addDisposableTo(disposeBag)
  }
  func setVerificationButtonText(){
    if count == 0 {
      self.verificationButton.enabled = true
      self.timer?.invalidate()
      self.verificationButton.setTitle("发送验证码", forState: .Normal)
    }else{
      self.verificationButton.setTitle("\(count)秒", forState: .Disabled)
      count--
    }
  }
  func phonelogin() {
    self.pleaseWait("正在登录中")
    self.verificationButton.enabled = true
    self.timer?.invalidate()
    self.view.userInteractionEnabled = false
    CupProvider.request(.PhoneLogin(self.phoneTextField.text!)).filterSuccessfulStatusCodes().mapJSON().observeOn(MainScheduler.instance).subscribe(onNext: { (let json) -> Void in
      self.clearAllNotice()
      staticAccount = AccountModel.toModel(json as! [String : AnyObject])
      AccountModel.localSave()
//      if staticIdentifier == nil {
//        self.presentViewController(CentralViewController(), animated: true, completion: nil)
//      }else{
        UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.instance.instantiateInitialViewController()
//      }
      }, onError: {
        self.clearAllNotice()
        self.view.userInteractionEnabled = true
        if let error = $0 as? NSError, let response = error.userInfo["data"] as? Moya.Response {
          self.noticeError(JSON(data: response.data)["message"].stringValue, autoClear: true)
        }
        
    }).addDisposableTo(disposeBag)
  }
  deinit{
    self.timer?.invalidate()
  }
  
}
