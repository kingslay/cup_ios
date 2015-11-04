//
//  CupProvider.swift
//  Cup
//
//  Created by kingslay on 15/11/2.
//  Copyright © 2015年 king. All rights reserved.
//

import Foundation
import Moya
let SCREEN_BOUND = UIScreen.mainScreen().bounds
let SCREEN_WIDTH = SCREEN_BOUND.width
let SCREEN_HEIGHT = SCREEN_BOUND.height
let SCREEN_SCALE = UIScreen.mainScreen().scale
let SCREEN_RATIO = SCREEN_WIDTH/320.0
let CupProvider = RxMoyaProvider<CupMoya>(endpointClosure: { (let target) -> Endpoint<CupMoya> in
    let url = target.baseURL.URLByAppendingPathComponent(target.path).absoluteString
    switch target {
    case .Regist(_,_):
        return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: .JSON)
    default:
        return Endpoint(URL: url, sampleResponseClosure: {.NetworkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
        
    }
    
})

public enum CupMoya {
    case Login(String,String)
    case Regist(String,String)
}

extension CupMoya : MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: "http://localhost:8080")! }
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/user/login"
        case .Regist(_,_):
            return "/user/regist"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .Regist(_,_):
            return .POST
        default:
            return .GET
        }
    }
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Regist(let user,let password):
            return ["username":user,"password":password]
        case .Login(let user,let password):
            return ["username":user,"password":password]
        default:
            return nil
        }
    }
    
    public var sampleData: NSData {        return "Half measures are as bad as nothing at all.".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}