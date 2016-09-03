//
//  UserLoginViewController.swift
//  PolyGe
//
//  Created by king on 15/4/20.
//  Copyright (c) 2015年 king. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import Moya
import SwiftyJSON
import KSJSONHelp
class UserLoginViewController: UIViewController,UITextFieldDelegate{
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPassTextField: UITextField!
    @IBOutlet weak var userLoginBtn: UIButton!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let username = defaults.stringForKey("username")
        if username != nil {
            userNameTextField.text = username
        }
        let password = defaults.stringForKey("password")
        if password != nil {
            userPassTextField.text = password
        }
    }
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.userNameTextField {
            self.userNameTextField.resignFirstResponder()
            self.userPassTextField.becomeFirstResponder()
        }else if textField == self.userPassTextField {
            self.userPassTextField.resignFirstResponder()
            self.login(self.userLoginBtn)
        }
        return true
    }
    
    //MARK: action
    @IBAction func login(sender: UIButton?) {
        guard let userName = self.userNameTextField.text where userName.characters.count > 0 else{
            self.ks.noticeError("用户名不能为空",autoClear: true)
            return
        }
        guard let password = self.userPassTextField.text where password.characters.count > 0 else{
            self.ks.noticeError("密码不能为空",autoClear: true)
            return
        }
        self.navigationController?.view.userInteractionEnabled = false
        self.ks.pleaseWait("正在登录中")
        CupProvider.request(.Login(userName,password)).filterSuccessfulStatusCodes().mapJSON().observeOn(MainScheduler.instance).subscribe(onNext: { (let json) -> Void in
            self.ks.clearAllNotice()
            staticAccount = AccountModel(from: json as! [String : AnyObject])
            AccountModel.localSave()
//            if staticIdentifier == nil {
//               UIApplication.sharedApplication().keyWindow!.rootViewController = CentralViewController()
//            }else{
                UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.initialViewController()
//            }
            }, onError: {
                self.ks.clearAllNotice()
                self.navigationController?.view.userInteractionEnabled = true
                if let error = $0 as? Moya.Error, let response = error.response {
                    self.ks.noticeError(JSON(data: response.data)["message"].stringValue, autoClear: true)
                }
                
        }).addDisposableTo(disposeBag)
    }
}
