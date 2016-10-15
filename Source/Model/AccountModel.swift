//
//  AccountModel.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
import KSJSONHelp
import KSSwiftExtension
class AccountModel: NSObject,Model,Storable {
    override required init() {
        super.init()
    }
    var accountid: Int = 0 {
        didSet{
            AccountModel.localSave()
        }
    }

    var nickname: String? {
        didSet{
            AccountModel.localSave()
        }
    }

    var avatar: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    //性别
    var sex: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    var phone: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    //场景
    var scene: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    //体质
    var constitution: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    var height: NSNumber? {
        didSet{
            AccountModel.localSave()
        }
    }
    var weight: NSNumber? {
        didSet{
            AccountModel.localSave()
        }
    }
    //饮水目标
    var waterplan: NSNumber? {
        didSet{
            AccountModel.localSave()
        }
    }
    var birthday: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    class func localSave() {
        if let account = staticAccount {
            UserDefaults.standard.set(account.dictionary, forKey: "sharedAccount")
        }
    }
    class func remoteSave() {
        CupProvider.request(.saveMe).subscribeNext {_ in
        }
    }
    func calculateProposalWater() -> Int {
        var age = 18
        if let birthday = self.birthday,let year = Int(birthday[0..<4]) {
            age = Date().ks.year - year
        }
        var bmi = 2100/21.0
        if age < 10 {
            bmi = 1050/17
        } else if age < 16 {
            bmi = 1800/19
        }
        let weight = (self.weight ?? 60).doubleValue
        let height = (self.height ?? 170).doubleValue/100.0
        let proposalWater = (35.0*weight + bmi * weight/(height*height))/2
        return Int(proposalWater);
    }
}
var staticAccount: AccountModel?
var staticIdentifier: String? {
    get{
        return UserDefaults.standard.string(forKey: "sharedIdentifier")
    }
    set{
        UserDefaults.standard.set(newValue, forKey: "sharedIdentifier")
        UserDefaults.standard.synchronize()
    }
}

