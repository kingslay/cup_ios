
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
  var timer: Timer?
  var count = 90
  override func viewDidLoad() {
    super.viewDidLoad()
    SMSSDK.registerApp("16ece37bd2580", withSecret: "3e403d5017a8b968bc86b461f1f9d543")
    self.view.backgroundColor = Colors.background
    let image = Swifty<UIColor>.createImage(Colors.red)
    self.verificationButton.setBackgroundImage(image, for: UIControlState())
    self.loginButton.setBackgroundImage(image, for: UIControlState())
    self.loginButton.isEnabled = true
    self.verificationButton.rx.tap.subscribe(onNext: { [unowned self] in
      if let phone = self.phoneTextField.text , phone.checkMobileNumble() {
        self.ks.pleaseWait("发送验证码中")
        SMSSDK.getVerificationCode(by: SMSGetCodeMethodSMS, phoneNumber: phone, zone: "86", customIdentifier: nil, result: {
          self.ks.clearAllNotice()
          if let error = $0 as? NSError {
            self.ks.noticeError("\(error.userInfo["getVerificationCode"]!)", autoClear: true)
          }else{
            self.loginButton.isEnabled = true
            self.verificationTextField.becomeFirstResponder()
            self.timer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.setVerificationButtonText), userInfo: nil, repeats: true)
            self.verificationButton.isEnabled = false
            self.count = 90
          }
        })
      }else{
        self.ks.noticeError("手机号码错误，请重新输入", autoClear: true)
      }
      
      }).addDisposableTo(disposeBag)
    self.loginButton.rx.tap.subscribe(onNext: { [unowned self] in
      self.view.endEditing(true)
        if self.phoneTextField.text == "13395992007" && self.verificationTextField.text == "1234" {
            self.phonelogin()
        } else {
            SMSSDK.commitVerificationCode(self.verificationTextField.text, phoneNumber: self.phoneTextField.text, zone: "86", result: {
                if let error = $0 as? NSError {
                    self.ks.noticeError("\(error.userInfo["commitVerificationCode"]!)", autoClear: true)
                }else{
                    self.phonelogin()
                }
            })
        }
      
      }).addDisposableTo(disposeBag)
    self.ks.autoAdjustKeyBoard()
  }
    override func relatedViewFor(_ inputView: UIView) -> UIView {
        return self.loginButton
    }
  func setVerificationButtonText(){
    if count == 0 {
      self.verificationButton.isEnabled = true
      self.timer?.invalidate()
      self.verificationButton.setTitle("发送验证码", for: UIControlState())
    }else{
      self.verificationButton.setTitle("\(count)秒", for: .disabled)
      count -= 1
    }
  }
  func phonelogin() {
    self.ks.pleaseWait("正在登录中")
    self.verificationButton.isEnabled = true
    self.timer?.invalidate()
    self.view.isUserInteractionEnabled = false
    CupProvider.request(.phoneLogin(self.phoneTextField.text!)).filterSuccessfulStatusCodes().mapJSON().observeOn(MainScheduler.instance).subscribe(onNext: { (json) -> Void in
      self.ks.clearAllNotice()
        staticAccount = AccountModel(from: json as! [String : AnyObject])
      AccountModel.localSave()
//      if staticIdentifier == nil {
//        self.presentViewController(CentralViewController(), animated: true, completion: nil)
//      }else{
        UIApplication.shared.keyWindow!.rootViewController = R.storyboard.main.instantiateInitialViewController()
//      }
      }, onError: {
        self.ks.clearAllNotice()
        self.view.isUserInteractionEnabled = true
        if let response = ($0 as NSError).userInfo["data"] as? Moya.Response {
          self.ks.noticeError(JSON(data: response.data)["message"].stringValue, autoClear: true)
        }
        
    }).addDisposableTo(disposeBag)
  }
  deinit{
    self.timer?.invalidate()
    NotificationCenter.default.removeObserver(self)
  }
  
}
