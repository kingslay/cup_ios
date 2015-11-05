//
//  AccountModel.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
class AccountModel: NSObject {
    var accountid: String!
    var nickname: String?
    var headImageURL: String?
    var brithday: String?
    var height: NSNumber?
    var city: String?
    
    class var sharedAccount: AccountModel?{
        get{
            if let account = staticAccount {
                return account
            }else{
                guard let dic = NSUserDefaults.standardUserDefaults().objectForKey("sharedAccount") as? NSDictionary else{return nil}
                return AccountModel.toModel(dic)
            }
        }
        set{
            staticAccount = newValue
            NSUserDefaults.standardUserDefaults().setObject(staticAccount?.toDictionary(), forKey: "sharedAccount")
        }
    }
}
var staticAccount: AccountModel?
var staticIdentifier: NSUUID?