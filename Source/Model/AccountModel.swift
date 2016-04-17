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
    
    var birthday: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    
    
    class func localSave() {
        if let account = staticAccount {
            NSUserDefaults.standardUserDefaults().setObject(account.dictionary, forKey: "sharedAccount")
        }
    }
    class func remoteSave() {
        CupProvider.request(.SaveMe).subscribeNext {_ in
        }
    }
}
var staticAccount: AccountModel?
var staticIdentifier: String? {
get{
    return NSUserDefaults.standardUserDefaults().stringForKey("sharedIdentifier")
}
set{
    NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "sharedIdentifier")
    NSUserDefaults.standardUserDefaults().synchronize()
}
}
