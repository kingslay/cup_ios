//
//  AccountModel.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
class AccountModel: NSObject {
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

    var birthday: String? {
        didSet{
            AccountModel.localSave()
        }
    }

    var height: NSNumber? {
        didSet{
            AccountModel.localSave()
        }
    }

    
    var city: String? {
        didSet{
            AccountModel.localSave()
        }
    }
    
    class func localSave() {
        if let account = staticAccount {
            NSUserDefaults.standardUserDefaults().setObject(account.toDictionary(), forKey: "sharedAccount")
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
}
}
