//
//  KSRegistViewController.swift
//  PolyGe
//
//  Created by king on 15/6/22.
//  Copyright © 2015年 king. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import Moya
import SwiftyJSON
import KSSwiftExtension
class UserRegistViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPassTextField: UITextField!
    @IBOutlet weak var confirmUserPassTextField: UITextField!
    @IBOutlet weak var userRegisterButton: UIButton!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.userNameTextField {
            self.userNameTextField.resignFirstResponder()
            self.userPassTextField.becomeFirstResponder()
        }else if textField == self.userPassTextField {
            self.userPassTextField.resignFirstResponder()
            self.confirmUserPassTextField.becomeFirstResponder()
        }else if textField == self.confirmUserPassTextField {
            self.confirmUserPassTextField.resignFirstResponder()
            self.register(self.userRegisterButton)
        }
        return true
    }
    //MARK: action
    @IBAction func register(sender: UIButton?) {
        guard let userName = self.userNameTextField.text where userName.characters.count > 0 else{
            self.noticeError("用户名不能为空",autoClear: true)
            return
        }
        guard let password = self.userPassTextField.text where password.characters.count > 0 else{
            self.noticeError("密码不能为空",autoClear: true)
            return
        }
        guard let confirmPassword = self.confirmUserPassTextField.text where confirmPassword == password else{
            self.noticeError("密码不一致请重新输入",autoClear: true)
            return
        }
        self.pleaseWait("正在登录中")
        self.navigationController?.view.userInteractionEnabled = false
        CupProvider.request(.Regist(userName,password)).filterSuccessfulStatusCodes().mapJSON().observeOn(MainScheduler.instance).subscribe(onNext: { (let json) -> Void in
            self.clearAllNotice()
            staticAccount = AccountModel(from: json as! [String : AnyObject])
            AccountModel.localSave()
            if staticIdentifier == nil {
                self.navigationController?.pushViewController(CentralViewController())
            }else{
                UIApplication.sharedApplication().keyWindow!.rootViewController = R.storyboard.main.initialViewController()
            }
            }, onError: {
                self.clearAllNotice()
                self.navigationController?.view.userInteractionEnabled = true
                if let error = $0 as? NSError, let response = error.userInfo["data"] as? Moya.Response {
                    self.noticeError(JSON(data: response.data)["message"].stringValue, autoClear: true)
                }
                
        }).addDisposableTo(disposeBag)
    }
}
