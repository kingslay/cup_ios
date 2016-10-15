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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    @IBAction func register(_ sender: UIButton?) {
        guard let userName = self.userNameTextField.text , userName.characters.count > 0 else{
            self.ks.noticeError("用户名不能为空",autoClear: true)
            return
        }
        guard let password = self.userPassTextField.text , password.characters.count > 0 else{
            self.ks.noticeError("密码不能为空",autoClear: true)
            return
        }
        guard let confirmPassword = self.confirmUserPassTextField.text , confirmPassword == password else{
            self.ks.noticeError("密码不一致请重新输入",autoClear: true)
            return
        }
        self.ks.pleaseWait("正在登录中")
        self.navigationController?.view.isUserInteractionEnabled = false
        CupProvider.request(.regist(userName,password)).filterSuccessfulStatusCodes().mapJSON().observeOn(MainScheduler.instance).subscribe(onNext: { (json) -> Void in
            self.ks.clearAllNotice()
            staticAccount = AccountModel(from: json as! [String : AnyObject])
            AccountModel.localSave()
            if staticIdentifier == nil {
                self.navigationController?.ks.pushViewController(CentralViewController())
            }else{
                UIApplication.shared.keyWindow!.rootViewController = R.storyboard.main.instantiateInitialViewController()
            }
            }, onError: {
                self.ks.clearAllNotice()
                self.navigationController?.view.isUserInteractionEnabled = true
                if let response = ($0 as NSError).userInfo["data"] as? Moya.Response {
                    self.ks.noticeError(JSON(data: response.data)["message"].stringValue, autoClear: true)
                }
                
        }).addDisposableTo(disposeBag)
    }
}
