//
//  AccountModel.swift
//  Cup
//
//  Created by kingslay on 15/11/4.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
class AccountModel: NSObject {
    ///昵称
    @property(nonatomic, strong) NSString *nickname;
    ///生日
    @property(nonatomic, strong) NSString *brithday;
    ///身高
    @property(nonatomic) float heigth;
    ///婚否
    @property(nonatomic) BOOL bMarry;
    @property(nonatomic, strong) NSString *headImageURL;

}