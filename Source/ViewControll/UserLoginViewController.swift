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
            self.noticeError("用户名不能为空",autoClear: true)
            return
        }
        guard let password = self.userPassTextField.text where password.characters.count > 0 else{
            self.noticeError("密码不能为空",autoClear: true)
            return
        }
        self.navigationController?.view.userInteractionEnabled = false
        self.noticeOnlyText("正在登录中")
        CupProvider.request(.Login(userName,password)).mapJSON().observeOn(MainScheduler.sharedInstance).subscribeNext { (let json) -> Void in
            AccountModel.sharedAccount = AccountModel.toModel(json as! NSDictionary)
            if staticIdentifier == nil {
                self.navigationController?.ks_pushViewController(CentralViewController())
            }else{
                UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.instance.instantiateInitialViewController()
            }
            }.addDisposableTo(disposeBag)
    }
}
